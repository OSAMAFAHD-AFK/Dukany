import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/date_formatter.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../data/models/customer_entry_model.dart';

/// Shows the items of one operation. Returns true if "delete" was pressed.
Future<bool> showCustomerEntryDetailsSheet(BuildContext context, CustomerEntryModel entry) async {
  final shouldDelete = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => CustomerEntryDetailsSheetBody(entry: entry),
  );
  return shouldDelete ?? false;
}

class CustomerEntryDetailsSheetBody extends StatelessWidget {
  const CustomerEntryDetailsSheetBody({super.key, required this.entry});

  final CustomerEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final color = entry.isDebt ? AppColors.debt : AppColors.paid;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.isDebt ? 'مشتريات بالدين' : 'تسديد', style: AppTextStyles.headline),
            Text(formatDateTime(entry.createdAt), style: AppTextStyles.caption),
            const SizedBox(height: 16),
            if (entry.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.fieldFill,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Column(
                  children: [
                    for (final item in entry.items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(item.name, style: AppTextStyles.bodyMedium)),
                            AmountText(amount: item.price, fontSize: 15),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            if (entry.note?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text('ملاحظة: ${entry.note}', style: AppTextStyles.body),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Text('المبلغ', style: AppTextStyles.subtitle)),
                AmountText(amount: entry.amount, color: color, fontSize: 22),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'حذف هذه العملية',
              icon: Icons.delete_outline_rounded,
              variant: CustomButtonVariant.outlined,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}
