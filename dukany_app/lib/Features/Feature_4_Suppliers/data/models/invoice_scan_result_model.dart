import 'package:equatable/equatable.dart';

/// What OCR found on the invoice photo. The owner always confirms.
class InvoiceScanResultModel extends Equatable {
  const InvoiceScanResultModel({required this.suggestedTotal, required this.candidates});

  /// Best guess for the invoice total (null if nothing readable).
  final double? suggestedTotal;

  /// Other numbers found, largest first, so the owner can tap the right one.
  final List<double> candidates;

  static const InvoiceScanResultModel empty = InvoiceScanResultModel(suggestedTotal: null, candidates: []);

  @override
  List<Object?> get props => [suggestedTotal, candidates];
}
