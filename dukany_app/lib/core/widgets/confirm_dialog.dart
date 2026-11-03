import 'package:flutter/material.dart';

import 'custom_button.dart';

/// Returns true only if the user pressed the confirm button.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool isDanger = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'إلغاء',
                variant: CustomButtonVariant.outlined,
                height: 50,
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                label: confirmLabel,
                variant: isDanger ? CustomButtonVariant.danger : CustomButtonVariant.primary,
                height: 50,
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
