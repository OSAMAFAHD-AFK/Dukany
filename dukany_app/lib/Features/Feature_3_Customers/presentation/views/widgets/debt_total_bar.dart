import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../../../core/widgets/custom_button.dart';

/// Sticky bottom bar: live total + save button.
class DebtTotalBar extends StatelessWidget {
  const DebtTotalBar({
    super.key,
    required this.total,
    required this.itemsCount,
    required this.isSaving,
    required this.onSave,
  });

  final double total;
  final int itemsCount;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المجموع ($itemsCount صنف)', style: AppTextStyles.caption),
                AmountText(amount: total, fontSize: 24),
              ],
            ),
          ),
          CustomButton(
            label: 'حفظ الدين',
            icon: Icons.check_rounded,
            expand: false,
            isLoading: isSaving,
            onPressed: total > 0 ? onSave : null,
          ),
        ],
      ),
    );
  }
}
