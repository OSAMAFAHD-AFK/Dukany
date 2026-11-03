import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/app_card.dart';

/// Big square entry point ("الزبائن" / "الموردين").
class HomeSectionTile extends StatelessWidget {
  const HomeSectionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.dark = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : AppColors.ink;
    return AppCard(
      onTap: onTap,
      color: dark ? AppColors.inkSoft : AppColors.surface,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: dark ? AppColors.accent : AppColors.fieldFill,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(icon, color: AppColors.ink),
              ),
              const Spacer(),
              Icon(Icons.arrow_back_rounded, color: foreground.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 28),
          Text(title, style: AppTextStyles.title.copyWith(color: foreground)),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(color: dark ? AppColors.textOnInkSecondary : null),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
