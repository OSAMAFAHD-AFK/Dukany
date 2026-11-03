import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/money_formatter.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../data/models/dashboard_summary_model.dart';

/// "How much is owed to me" — the number the owner cares about most.
class BalancesHeroCard extends StatelessWidget {
  const BalancesHeroCard({super.key, required this.summary});

  final DashboardSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.extraLarge)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ديونك عند الزبائن', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnInkSecondary)),
          const SizedBox(height: 4),
          AmountText(
            amount: summary.customersOwe,
            color: Colors.white,
            fontSize: 36,
            currencyColor: AppColors.textOnInkSecondary,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: AppColors.inkSoft, borderRadius: BorderRadius.circular(AppRadius.medium)),
            child: Row(
              children: [
                const Icon(Icons.today_rounded, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text('اليوم', style: AppTextStyles.caption.copyWith(color: AppColors.textOnInkSecondary)),
                const Spacer(),
                Text(
                  '+${formatMoney(summary.todayDebts)} دين',
                  style: AppTextStyles.caption.copyWith(color: const Color(0xFFFF8A8D), fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Text(
                  '${formatMoney(summary.todayCollected)} تحصيل',
                  style: AppTextStyles.caption.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
