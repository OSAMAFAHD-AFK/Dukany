import '../../../../core/utils/functions/date_formatter.dart';
import '../../../../core/utils/functions/money_formatter.dart';
import '../models/statement_model.dart';

/// Plain-text statement for WhatsApp (when a PDF is too much).
abstract class StatementTextBuilder {
  static String build(StatementModel statement) {
    final buffer = StringBuffer()
      ..writeln('كشف حساب — ${statement.shopName}')
      ..writeln('الاسم: ${statement.partyName}')
      ..writeln('الفترة: ${_periodText(statement)}')
      ..writeln('------------------');

    if (statement.from != null) {
      buffer.writeln('رصيد سابق: ${formatMoneyWithCurrency(statement.openingBalance)}');
    }
    for (final line in statement.lines) {
      final sign = line.debit > 0 ? '+' : '-';
      final amount = line.debit > 0 ? line.debit : line.credit;
      buffer.writeln('${formatDate(line.date)} | ${line.description} | $sign${formatMoney(amount)}');
    }

    buffer
      ..writeln('------------------')
      ..writeln('${statement.debitLabel}: ${formatMoneyWithCurrency(statement.totalDebit)}')
      ..writeln('${statement.creditLabel}: ${formatMoneyWithCurrency(statement.totalCredit)}')
      ..writeln('${statement.balanceLabel}: ${formatMoneyWithCurrency(statement.closingBalance)}');
    return buffer.toString().trim();
  }

  static String _periodText(StatementModel statement) {
    if (statement.from == null) return 'كل الحساب';
    final end = statement.to?.subtract(const Duration(days: 1)) ?? DateTime.now();
    return 'من ${formatDate(statement.from!)} إلى ${formatDate(end)}';
  }
}
