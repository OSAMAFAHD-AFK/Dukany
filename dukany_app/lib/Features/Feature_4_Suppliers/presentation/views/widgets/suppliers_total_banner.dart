import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';

class SuppliersTotalBanner extends StatelessWidget {
  const SuppliersTotalBanner({super.key, required this.totalDue, required this.suppliersCount});

  final double totalDue;
  final int suppliersCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(AppRadius.large)),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(child: Text('عليك لـ $suppliersCount مورد', style: AppTextStyles.bodyMedium)),
          AmountText(amount: totalDue, fontSize: 17),
        ],
      ),
    );
  }
}
