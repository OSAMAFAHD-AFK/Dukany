const List<String> arabicMonthNames = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// 2026/11/02
String formatDate(DateTime date) => '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';

/// 08:30 م
String formatTime(DateTime date) {
  final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final period = date.hour < 12 ? 'ص' : 'م';
  return '${_twoDigits(hour12)}:${_twoDigits(date.minute)} $period';
}

/// 2026/11/02 - 08:30 م
String formatDateTime(DateTime date) => '${formatDate(date)} - ${formatTime(date)}';

/// اليوم / أمس / 2026/11/02
String formatRelativeDay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final difference = today.difference(day).inDays;
  if (difference == 0) return 'اليوم';
  if (difference == 1) return 'أمس';
  return formatDate(date);
}

/// نوفمبر 2026
String formatMonthYear(DateTime date) => '${arabicMonthNames[date.month - 1]} ${date.year}';
