import '../../../../core/utils/functions/date_formatter.dart';
import '../../../../core/utils/functions/money_formatter.dart';
import '../models/customer_entry_model.dart';

/// Builds the WhatsApp text sent to a customer after each operation.
/// One message per operation — all the items taken are listed together.
abstract class CustomerMessageBuilder {
  static String build({
    required String customerName,
    required String shopName,
    required CustomerEntryModel entry,
    required double newBalance,
  }) {
    final lines = <String>['السلام عليكم $customerName'];

    if (entry.isDebt) {
      lines.add('تم تسجيل مشتريات على حسابك لدى $shopName:');
      for (final item in entry.items) {
        lines.add('- ${item.name}: ${formatMoneyWithCurrency(item.price)}');
      }
      lines.add('المجموع: ${formatMoneyWithCurrency(entry.amount)}');
    } else {
      lines.add('تم استلام دفعة بمبلغ ${formatMoneyWithCurrency(entry.amount)} من حسابك لدى $shopName.');
    }

    if (entry.note?.isNotEmpty == true && entry.isDebt) lines.add('ملاحظة: ${entry.note}');
    lines.add(_balanceLine(newBalance));
    lines.add('التاريخ: ${formatDateTime(entry.createdAt)}');
    lines.add('شكراً لتعاملكم معنا');
    return lines.join('\n');
  }

  static String _balanceLine(double balance) {
    if (balance > 0) return 'إجمالي حسابك الآن: ${formatMoneyWithCurrency(balance)}';
    if (balance < 0) return 'لك رصيد لدينا: ${formatMoneyWithCurrency(-balance)}';
    return 'حسابك مسدد بالكامل';
  }
}
