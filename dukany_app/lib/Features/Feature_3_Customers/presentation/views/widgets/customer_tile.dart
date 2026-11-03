import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/date_formatter.dart';
import '../../../../../core/utils/functions/phone_normalizer.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/party_avatar.dart';
import '../../../data/models/customer_model.dart';

class CustomerTile extends StatelessWidget {
  const CustomerTile({super.key, required this.customer, required this.onTap});

  final CustomerModel customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lastActivity = customer.lastEntryAt;
    final subtitle = lastActivity != null
        ? 'آخر عملية: ${formatRelativeDay(lastActivity)}'
        : customer.hasPhone
        ? formatPhoneForDisplay(customer.phone!)
        : 'لا توجد عمليات بعد';

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          PartyAvatar(name: customer.name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: AppTextStyles.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _BalanceBadge(balance: customer.balance),
        ],
      ),
    );
  }
}

class _BalanceBadge extends StatelessWidget {
  const _BalanceBadge({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    if (balance <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AppColors.paidSoft, borderRadius: BorderRadius.circular(100)),
        child: Text(
          'مسدد',
          style: AppTextStyles.caption.copyWith(color: AppColors.paid, fontWeight: FontWeight.w600),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('عليه', style: AppTextStyles.caption.copyWith(fontSize: 11)),
        AmountText(amount: balance, color: AppColors.debt, fontSize: 16),
      ],
    );
  }
}
