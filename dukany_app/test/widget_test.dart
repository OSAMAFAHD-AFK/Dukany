import 'package:dukany_app/core/utils/functions/money_formatter.dart';
import 'package:dukany_app/core/utils/functions/phone_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeYemeniPhone', () {
    test('accepts the usual ways of typing a Yemeni mobile', () {
      expect(normalizeYemeniPhone('777123456'), '967777123456');
      expect(normalizeYemeniPhone('0777123456'), '967777123456');
      expect(normalizeYemeniPhone('+967 777 123 456'), '967777123456');
      expect(normalizeYemeniPhone('00967777123456'), '967777123456');
      expect(normalizeYemeniPhone('٧٧٧١٢٣٤٥٦'), '967777123456');
    });

    test('rejects garbage', () {
      expect(normalizeYemeniPhone('123'), isNull);
      expect(normalizeYemeniPhone(''), isNull);
    });
  });

  group('parseMoney', () {
    test('reads Western and Arabic digits with separators', () {
      expect(parseMoney('15,000'), 15000);
      expect(parseMoney('١٥٬٠٠٠'), 15000);
      expect(parseMoney('500.5'), 500.5);
    });

    test('rejects zero, negatives and text', () {
      expect(parseMoney('0'), isNull);
      expect(parseMoney('-5'), isNull);
      expect(parseMoney('abc'), isNull);
    });
  });
}
