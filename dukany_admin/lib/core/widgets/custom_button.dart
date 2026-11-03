import 'package:flutter/material.dart';

import '../utils/style.dart';
import '../utils/theme.dart';

enum CustomButtonVariant { primary, outlined, success, danger, soft }

/// The one pill-shaped button used across the app.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = CustomButtonVariant.primary,
    this.height = 56,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final CustomButtonVariant variant;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(variant);
    final child = isLoading
        ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: colors.foreground))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 22, color: colors.foreground), const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.button.copyWith(color: colors.foreground),
                ),
              ),
            ],
          );

    return SizedBox(
      width: expand ? double.infinity : null,
      height: height,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: colors.background,
          disabledBackgroundColor: colors.background.withValues(alpha: 0.45),
          foregroundColor: colors.foreground,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: StadiumBorder(
            side: variant == CustomButtonVariant.outlined
                ? const BorderSide(color: AppColors.ink, width: 1.4)
                : BorderSide.none,
          ),
        ),
        child: child,
      ),
    );
  }

  ({Color background, Color foreground}) _colorsFor(CustomButtonVariant variant) {
    switch (variant) {
      case CustomButtonVariant.primary:
        return (background: AppColors.ink, foreground: Colors.white);
      case CustomButtonVariant.outlined:
        return (background: Colors.transparent, foreground: AppColors.ink);
      case CustomButtonVariant.success:
        return (background: AppColors.paid, foreground: Colors.white);
      case CustomButtonVariant.danger:
        return (background: AppColors.debt, foreground: Colors.white);
      case CustomButtonVariant.soft:
        return (background: AppColors.surface, foreground: AppColors.ink);
    }
  }
}
