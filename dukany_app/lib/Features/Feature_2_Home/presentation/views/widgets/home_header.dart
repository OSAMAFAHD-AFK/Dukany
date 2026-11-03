import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/dukany_logo.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.shopName, required this.onAccountTap});

  final String shopName;
  final VoidCallback onAccountTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DukanyLogo(size: 46, showName: false),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('أهلاً بك 👋', style: AppTextStyles.caption),
              Text(shopName, style: AppTextStyles.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: 'حسابي والاشتراك',
            onPressed: onAccountTap,
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ),
      ],
    );
  }
}
