import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'empty_state_view.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: Icons.error_outline_rounded,
      title: 'حدث خطأ',
      message: message,
      action: onRetry == null
          ? null
          : CustomButton(label: 'حاول مرة أخرى', icon: Icons.refresh_rounded, onPressed: onRetry, expand: false),
    );
  }
}
