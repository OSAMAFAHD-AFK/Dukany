/// Converts Arabic-Indic (٠-٩) and Persian (۰-۹) digits and separators
/// to Western ones so every number the user types can be parsed.
String toWesternDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.writeCharCode(rune - 0x0660 + 0x30);
    } else if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.writeCharCode(rune - 0x06F0 + 0x30);
    } else if (rune == 0x066B) {
      buffer.write('.'); // Arabic decimal separator
    } else if (rune == 0x066C) {
      buffer.write(','); // Arabic thousands separator
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}
