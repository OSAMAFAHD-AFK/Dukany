import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../../core/utils/functions/digits_normalizer.dart';
import '../models/invoice_scan_result_model.dart';

/// On-device OCR (works offline). ML Kit reads the digits of the invoice;
/// we then guess which number is the total:
///   1. a number on the same row as "Total / الإجمالي / المجموع / الصافي"
///   2. otherwise the largest believable amount.
class InvoiceTextRecognitionDataSource {
  static final RegExp _totalKeyword = RegExp(
    r'(total|grand|net|amount|balance|الاجمالي|الإجمالي|اجمالي|إجمالي|المجموع|الصافي|المطلوب)',
    caseSensitive: false,
  );
  static final RegExp _datePattern = RegExp(r'\d{1,4}\s*[/\-.]\s*\d{1,2}\s*[/\-.]\s*\d{1,4}');
  static final RegExp _timePattern = RegExp(r'\d{1,2}:\d{2}(:\d{2})?');
  static final RegExp _numberPattern = RegExp(r'\d{1,3}(?:,\d{3})+(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?');

  Future<InvoiceScanResultModel> recognizeTotal(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognized = await recognizer.processImage(InputImage.fromFilePath(imagePath));
      return _pickTotal(recognized);
    } finally {
      await recognizer.close();
    }
  }

  InvoiceScanResultModel _pickTotal(RecognizedText recognized) {
    final numbers = <({double value, Rect box})>[];
    final keywordBoxes = <Rect>[];

    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        final text = toWesternDigits(line.text);
        if (_totalKeyword.hasMatch(text)) keywordBoxes.add(line.boundingBox);
        final cleaned = text.replaceAll(_datePattern, ' ').replaceAll(_timePattern, ' ');
        for (final match in _numberPattern.allMatches(cleaned)) {
          final value = _toAmount(match.group(0)!);
          if (value != null) numbers.add((value: value, box: line.boundingBox));
        }
      }
    }
    if (numbers.isEmpty) return InvoiceScanResultModel.empty;

    double? keywordTotal;
    for (final keywordBox in keywordBoxes) {
      for (final number in numbers) {
        if (_onSameRow(keywordBox, number.box) && (keywordTotal == null || number.value > keywordTotal)) {
          keywordTotal = number.value;
        }
      }
    }

    final distinct = numbers.map((number) => number.value).toSet().toList()..sort((a, b) => b.compareTo(a));
    return InvoiceScanResultModel(
      suggestedTotal: keywordTotal ?? distinct.first,
      candidates: distinct.take(6).toList(),
    );
  }

  /// Filters out things that are clearly not money: tiny numbers,
  /// phone numbers (9-digit 7xxxxxxxx) and long references.
  double? _toAmount(String raw) {
    final digitsOnly = raw.replaceAll(',', '');
    final integerPart = digitsOnly.split('.').first;
    if (integerPart.length > 9) return null;
    if (!raw.contains(',') && integerPart.length == 9 && integerPart.startsWith('7')) return null;
    final value = double.tryParse(digitsOnly);
    if (value == null || value < 50) return null;
    return value;
  }

  bool _onSameRow(Rect a, Rect b) {
    final overlap = (a.bottom < b.bottom ? a.bottom : b.bottom) - (a.top > b.top ? a.top : b.top);
    return overlap > 0.4 * (a.height < b.height ? a.height : b.height);
  }
}
