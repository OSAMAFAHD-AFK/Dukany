import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';

class SendingAllBanner extends StatelessWidget {
  const SendingAllBanner({super.key, required this.remaining, required this.onStop});

  final int remaining;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.paidSoft, borderRadius: BorderRadius.circular(AppRadius.medium)),
      child: Row(
        children: [
          const Icon(Icons.chat_rounded, color: AppColors.paid),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'جاري الإرسال ($remaining متبقية): في واتساب اضغط "إرسال" ثم ارجع للتطبيق، وستُفتح الرسالة التالية تلقائياً',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          TextButton(onPressed: onStop, child: const Text('إيقاف')),
        ],
      ),
    );
  }
}
