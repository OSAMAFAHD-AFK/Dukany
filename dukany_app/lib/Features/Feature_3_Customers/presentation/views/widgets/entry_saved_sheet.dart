import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../data/models/saved_entry_result_model.dart';

/// Shown right after a debt/payment is saved.
/// Returns true when the owner chose "send on WhatsApp now".
Future<bool> showEntrySavedSheet(BuildContext context, SavedEntryResultModel result) async {
  final sendNow = await showModalBottomSheet<bool>(
    context: context,
    builder: (_) => EntrySavedSheetBody(result: result),
  );
  return sendNow ?? false;
}

class EntrySavedSheetBody extends StatelessWidget {
  const EntrySavedSheetBody({super.key, required this.result});

  final SavedEntryResultModel result;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.paidSoft, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 40, color: AppColors.paid),
            ),
            const SizedBox(height: 14),
            const Text('تم الحفظ', style: AppTextStyles.headline),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('إجمالي الحساب الآن: ', style: AppTextStyles.body),
                AmountText(amount: result.newBalance, fontSize: 17),
              ],
            ),
            const SizedBox(height: 22),
            if (result.hasQueuedMessage) ...[
              CustomButton(
                label: 'إرسال واتساب الآن',
                icon: Icons.send_rounded,
                variant: CustomButtonVariant.success,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 10),
              CustomButton(
                label: 'لاحقاً مع زر الرفع',
                variant: CustomButtonVariant.outlined,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ] else ...[
              const Text(
                'لا يوجد رقم جوال لهذا الزبون، لن تُرسل رسالة واتساب',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              CustomButton(label: 'تمام', onPressed: () => Navigator.of(context).pop(false)),
            ],
          ],
        ),
      ),
    );
  }
}
