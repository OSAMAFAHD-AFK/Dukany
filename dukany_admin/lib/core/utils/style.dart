import 'package:flutter/material.dart';

import 'theme.dart';

abstract class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.2,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.3,
  );

  static const TextStyle title = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    height: 1.35,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.ink, height: 1.5);

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2);
}
