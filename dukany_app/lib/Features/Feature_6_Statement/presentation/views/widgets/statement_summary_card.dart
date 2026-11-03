import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../data/models/statement_model.dart';

class StatementSummaryCard extends StatelessWidget {
  const StatementSummaryCard({super.key, required this.statement});

  final StatementModel statement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.extraLarge)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(statement.balanceLabel, style: AppTextStyles.caption.copyWith(color: AppColors.textOnInkSecondary)),
          AmountText(
            amount: statement.closingBalance,
            color: Colors.white,
            fontSize: 30,
            currencyColor: AppColors.textOnInkSecondary,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (statement.from != null)
                _SummaryItem(label: 'رصيد سابق', amount: statement.openingBalance, color: Colors.white),
              _SummaryItem(label: statement.debitLabel, amount: statement.totalDebit, color: const Color(0xFFFF8A8D)),
              _SummaryItem(label: statement.creditLabel, amount: statement.totalCredit, color: AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.amount, required this.color});

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textOnInkSecondary, fontSize: 12)),
          AmountText(amount: amount, color: color, fontSize: 15, currencyColor: AppColors.textOnInkSecondary),
        ],
      ),
    );
  }
}
