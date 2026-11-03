import 'package:flutter/material.dart';

import 'style.dart';

abstract class AppColors {
  static const Color background = Color(0xFFF2F2F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color fieldFill = Color(0xFFF5F5F7);
  static const Color border = Color(0xFFE7E7EB);

  static const Color ink = Color(0xFF111114);
  static const Color inkSoft = Color(0xFF26262C);
  static const Color textSecondary = Color(0xFF7A7A85);
  static const Color textOnInkSecondary = Color(0xFFA4A4AE);

  /// Lime highlight used sparingly (badges, hero accents).
  static const Color accent = Color(0xFFCDF464);

  /// Money the customer owes / money we owe a supplier.
  static const Color debt = Color(0xFFE5484D);
  static const Color debtSoft = Color(0xFFFDEDED);

  /// Payments received / settled balances.
  static const Color paid = Color(0xFF1E9E64);
  static const Color paidSoft = Color(0xFFE5F6EE);

  static const Color warning = Color(0xFFE59A12);
  static const Color warningSoft = Color(0xFFFFF4DF);
}

abstract class AppRadius {
  static const double small = 12;
  static const double medium = 16;
  static const double large = 24;
  static const double extraLarge = 32;
}

abstract class AppTheme {
  static const String fontFamily = 'IBMPlexSansArabic';

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.ink,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.debt,
      onError: Colors.white,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.ink,
        titleTextStyle: AppTextStyles.title,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(borderSide: const BorderSide(color: AppColors.ink, width: 1.4)),
        errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: AppColors.debt, width: 1.2)),
        focusedErrorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: AppColors.debt, width: 1.4)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        titleTextStyle: AppTextStyles.title,
        contentTextStyle: AppTextStyles.body,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.ink,
        side: const BorderSide(color: AppColors.border),
        labelStyle: AppTextStyles.bodyMedium,
        secondaryLabelStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        shape: const StadiumBorder(),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.ink),
    );
  }
}
