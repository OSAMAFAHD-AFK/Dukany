import 'package:flutter/material.dart';

import '../utils/style.dart';
import '../utils/theme.dart';

/// Brand mark: black rounded square with a lime storefront.
class DukanyLogo extends StatelessWidget {
  const DukanyLogo({super.key, this.size = 72, this.showName = true});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(size * 0.3)),
          child: Icon(Icons.storefront_rounded, color: AppColors.accent, size: size * 0.5),
        ),
        if (showName) ...[
          SizedBox(height: size * 0.18),
          Text('دُكاني', style: AppTextStyles.display.copyWith(fontSize: size * 0.42)),
        ],
      ],
    );
  }
}
