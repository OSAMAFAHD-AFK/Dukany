import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/password_generator.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../data/models/shop_model.dart';

/// Returns the new password, or null if cancelled.
Future<String?> showResetPasswordDialog(BuildContext context, ShopModel shop) {
  final controller = TextEditingController(text: generateShopPassword());
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('كلمة مرور جديدة لـ ${shop.name}'),
      content: SizedBox(
        width: 380,
        child: CustomTextField(
          controller: controller,
          label: 'كلمة المرور (6 أحرف على الأقل)',
          textDirection: TextDirection.ltr,
          suffix: IconButton(
            tooltip: 'توليد كلمة جديدة',
            onPressed: () => controller.text = generateShopPassword(),
            icon: const Icon(Icons.casino_outlined),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('إلغاء')),
        FilledButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text), child: const Text('حفظ')),
      ],
    ),
  );
}
