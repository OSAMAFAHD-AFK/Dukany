import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../data/models/shop_filter.dart';
import '../../manager/shops_cubit/shops_cubit.dart';

/// Totals at the top; tapping a card applies that filter.
class ShopsStatsRow extends StatelessWidget {
  const ShopsStatsRow({super.key, required this.state, required this.onFilterTap});

  final ShopsState state;
  final ValueChanged<ShopFilter> onFilterTap;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (ShopFilter.all, 'إجمالي البقالات', Icons.storefront_outlined, AppColors.ink, true),
      (ShopFilter.active, 'نشطة', Icons.verified_outlined, AppColors.paid, false),
      (ShopFilter.expiringSoon, 'تنتهي خلال 7 أيام', Icons.timelapse_rounded, AppColors.warning, false),
      (ShopFilter.suspended, 'موقوفة', Icons.block_rounded, AppColors.debt, false),
      (ShopFilter.expired, 'منتهية', Icons.event_busy_outlined, AppColors.textSecondary, false),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 900 ? 5 : (constraints.maxWidth > 560 ? 3 : 2);
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (filter, label, icon, color, dark) in cards)
              SizedBox(
                width: width,
                child: AppCard(
                  onTap: () => onFilterTap(filter),
                  color: dark ? AppColors.ink : AppColors.surface,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: dark ? AppColors.accent : color),
                      const SizedBox(height: 14),
                      Text(
                        '${state.countOf(filter)}',
                        style: AppTextStyles.display.copyWith(color: dark ? Colors.white : AppColors.ink),
                      ),
                      Text(
                        label,
                        style: AppTextStyles.caption.copyWith(color: dark ? AppColors.textOnInkSecondary : null),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
