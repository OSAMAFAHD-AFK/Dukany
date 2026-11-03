import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/date_formatter.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/party_avatar.dart';
import '../../../data/models/supplier_model.dart';

class SupplierTile extends StatelessWidget {
  const SupplierTile({super.key, required this.supplier, required this.onTap});

  final SupplierModel supplier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lastActivity = supplier.lastEntryAt;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          PartyAvatar(name: supplier.name, dark: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supplier.name, style: AppTextStyles.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  lastActivity == null ? 'لا توجد فواتير بعد' : 'آخر عملية: ${formatRelativeDay(lastActivity)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (supplier.balance <= 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.paidSoft, borderRadius: BorderRadius.circular(100)),
              child: Text(
                'مسدد',
                style: AppTextStyles.caption.copyWith(color: AppColors.paid, fontWeight: FontWeight.w600),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('عليك', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                AmountText(amount: supplier.balance, fontSize: 16),
              ],
            ),
        ],
      ),
    );
  }
}
