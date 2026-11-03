import 'package:intl/intl.dart';

import '../app_config.dart';
import 'digits_normalizer.dart';

final NumberFormat _moneyFormat = NumberFormat('#,##0.##', 'en_US');

/// 15000 → "15,000"
String formatMoney(num amount) => _moneyFormat.format(amount);

/// 15000 → "15,000 ريال"
String formatMoneyWithCurrency(num amount) => '${formatMoney(amount)} ${AppConfig.currencyLabel}';

/// "١٥٬٠٠٠" / "15,000" / "15000.5" → 15000.5, or null when not a positive number.
double? parseMoney(String? raw) {
  if (raw == null) return null;
  final cleaned = toWesternDigits(raw).replaceAll(',', '').replaceAll(' ', '').trim();
  final value = double.tryParse(cleaned);
  if (value == null || value <= 0 || value.isNaN || value.isInfinite) return null;
  return double.parse(value.toStringAsFixed(2));
}
