import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../data/models/shop_model.dart';

class ShopStatusBadge extends StatelessWidget {
  const ShopStatusBadge({super.key, required this.status});

  final ShopStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, foreground, background) = switch (status) {
      ShopStatus.active => ('نشطة', AppColors.paid, AppColors.paidSoft),
      ShopStatus.expiringSoon => ('تنتهي قريباً', AppColors.warning, AppColors.warningSoft),
      ShopStatus.expired => ('منتهية', AppColors.textSecondary, AppColors.fieldFill),
      ShopStatus.suspended => ('موقوفة', AppColors.debt, AppColors.debtSoft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(100)),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
