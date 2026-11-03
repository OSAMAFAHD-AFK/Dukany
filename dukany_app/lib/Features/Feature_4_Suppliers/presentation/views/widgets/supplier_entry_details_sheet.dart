import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/date_formatter.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../data/models/supplier_entry_model.dart';
import 'invoice_photo.dart';

typedef RemoteImageUrlLoader = Future<({String? url, String? error})> Function(SupplierEntryModel entry);

/// Invoice photo + amount. Returns true if "delete" was pressed.
Future<bool> showSupplierEntryDetailsSheet(
  BuildContext context,
  SupplierEntryModel entry,
  RemoteImageUrlLoader loadRemoteUrl,
) async {
  final shouldDelete = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => SupplierEntryDetailsSheetBody(entry: entry, loadRemoteUrl: loadRemoteUrl),
  );
  return shouldDelete ?? false;
}

class SupplierEntryDetailsSheetBody extends StatelessWidget {
  const SupplierEntryDetailsSheetBody({super.key, required this.entry, required this.loadRemoteUrl});

  final SupplierEntryModel entry;
  final RemoteImageUrlLoader loadRemoteUrl;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.isInvoice ? 'فاتورة بضاعة' : 'دفعة للمورد', style: AppTextStyles.headline),
            Text(formatDateTime(entry.createdAt), style: AppTextStyles.caption),
            if (entry.hasImage) ...[
              const SizedBox(height: 16),
              InvoicePhoto(entry: entry, loadRemoteUrl: loadRemoteUrl),
            ],
            if (entry.note?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text('ملاحظة: ${entry.note}', style: AppTextStyles.body),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text(entry.isInvoice ? 'إجمالي الفاتورة' : 'المبلغ', style: AppTextStyles.subtitle)),
                AmountText(amount: entry.amount, color: entry.isInvoice ? AppColors.ink : AppColors.paid, fontSize: 22),
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
