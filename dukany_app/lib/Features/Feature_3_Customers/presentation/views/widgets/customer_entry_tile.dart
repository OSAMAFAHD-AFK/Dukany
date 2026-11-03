import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/date_formatter.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/sync_state_icon.dart';
import '../../../data/models/customer_entry_model.dart';

class CustomerEntryTile extends StatelessWidget {
  const CustomerEntryTile({super.key, required this.entry, required this.onTap});

  final CustomerEntryModel entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDebt = entry.isDebt;
    final color = isDebt ? AppColors.debt : AppColors.paid;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDebt ? AppColors.debtSoft : AppColors.paidSoft,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(isDebt ? Icons.shopping_basket_outlined : Icons.payments_outlined, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.description, style: AppTextStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(formatDateTime(entry.createdAt), style: AppTextStyles.caption),
                    const SizedBox(width: 6),
                    SyncStateIcon(isSynced: entry.isSynced),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AmountText(amount: entry.amount, color: color, prefix: isDebt ? '+' : '−', fontSize: 16),
        ],
      ),
    );
  }
}
