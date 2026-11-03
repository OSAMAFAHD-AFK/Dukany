import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/custom_button.dart';

class InvoiceImageSourcePicker extends StatelessWidget {
  const InvoiceImageSourcePicker({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.onWithoutImage,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onWithoutImage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.extraLarge),
              ),
              child: const Icon(Icons.document_scanner_outlined, size: 56, color: AppColors.ink),
            ),
            const SizedBox(height: 24),
            const Text('صوّر فاتورة الجملة', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            const Text(
              'التطبيق يقرأ الإجمالي من الصورة تلقائياً، وتحتفظ بالصورة الأصلية مع الحساب',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            CustomButton(label: 'فتح الكاميرا', icon: Icons.photo_camera_outlined, onPressed: onCamera),
            const SizedBox(height: 10),
            CustomButton(
              label: 'اختيار من المعرض',
              icon: Icons.photo_library_outlined,
              variant: CustomButtonVariant.outlined,
              onPressed: onGallery,
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: onWithoutImage,
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
              child: const Text('بدون صورة — أكتب المبلغ فقط'),
            ),
          ],
        ),
      ),
    );
  }
}
