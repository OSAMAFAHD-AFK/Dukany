import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';

class CustomersTotalBanner extends StatelessWidget {
  const CustomersTotalBanner({super.key, required this.totalOwed, required this.customersCount});

  final double totalOwed;
  final int customersCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(color: AppColors.debtSoft, borderRadius: BorderRadius.circular(AppRadius.large)),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, color: AppColors.debt),
          const SizedBox(width: 10),
          Expanded(child: Text('مجموع الديون على $customersCount زبون', style: AppTextStyles.bodyMedium)),
          AmountText(amount: totalOwed, color: AppColors.debt, fontSize: 17),
        ],
      ),
    );
  }
}
