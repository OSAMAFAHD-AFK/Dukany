import 'digits_normalizer.dart';

/// Turns any way a Yemeni shop owner may type a number
/// (777123456 / 0777123456 / +967 777 123 456 / ٧٧٧١٢٣٤٥٦)
/// into international digits without "+" (967777123456).
///
/// Must stay identical to normalizeYemeniPhone() in the Edge Function.
String? normalizeYemeniPhone(String? raw) {
  if (raw == null) return null;
  var digits = toWesternDigits(raw).replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.startsWith('0')) digits = digits.substring(1);
  if (digits.length == 9 && digits.startsWith('7')) digits = '967$digits';
  return RegExp(r'^[0-9]{9,15}$').hasMatch(digits) ? digits : null;
}

/// 967777123456 → 777 123 456 (friendlier for display).
String formatPhoneForDisplay(String phone) {
  final local = phone.startsWith('967') ? phone.substring(3) : phone;
  if (local.length != 9) return local;
  return '${local.substring(0, 3)} ${local.substring(3, 6)} ${local.substring(6)}';
}
