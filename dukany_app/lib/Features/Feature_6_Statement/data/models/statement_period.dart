enum StatementPeriod {
  thisMonth('هذا الشهر'),
  lastMonth('الشهر الماضي'),
  lastThreeMonths('آخر 3 أشهر'),
  all('كل الحساب');

  const StatementPeriod(this.label);

  final String label;

  /// [from] inclusive, [to] exclusive. Null means "no limit".
  ({DateTime? from, DateTime? to}) rangeFrom(DateTime now) {
    final monthStart = DateTime(now.year, now.month);
    switch (this) {
      case StatementPeriod.thisMonth:
        return (from: monthStart, to: null);
      case StatementPeriod.lastMonth:
        return (from: DateTime(now.year, now.month - 1), to: monthStart);
      case StatementPeriod.lastThreeMonths:
        return (from: DateTime(now.year, now.month - 2), to: null);
      case StatementPeriod.all:
        return (from: null, to: null);
    }
  }
}
