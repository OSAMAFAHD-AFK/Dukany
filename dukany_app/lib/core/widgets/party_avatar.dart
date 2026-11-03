import 'package:flutter/material.dart';

import '../utils/style.dart';
import '../utils/theme.dart';

/// Round avatar with the first letter of a customer's / supplier's name.
class PartyAvatar extends StatelessWidget {
  const PartyAvatar({super.key, required this.name, this.size = 48, this.dark = false});

  final String name;
  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '؟' : trimmed.characters.first;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: dark ? AppColors.ink : AppColors.fieldFill, shape: BoxShape.circle),
      child: Text(
        letter,
        style: AppTextStyles.title.copyWith(
          fontSize: size * 0.4,
          color: dark ? Colors.white : AppColors.ink,
          height: 1,
        ),
      ),
    );
  }
}
