import 'package:flutter/material.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../manager/sync_cubit/sync_cubit.dart';

class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({super.key, required this.state});

  final SyncState state;

  @override
  Widget build(BuildContext context) {
    final report = state.report;
    final (icon, title, subtitle) = switch (state.phase) {
      SyncPhase.uploading => (Icons.cloud_sync_outlined, 'جاري الرفع...', 'لا تغلق التطبيق حتى ينتهي'),
      SyncPhase.uploaded => (
        Icons.cloud_done_rounded,
        'تم الرفع بنجاح',
        'رُفعت ${report?.uploadedRows ?? 0} عملية و ${report?.uploadedImages ?? 0} صورة فاتورة',
      ),
      SyncPhase.failed => (Icons.cloud_off_rounded, 'لم يكتمل الرفع', state.errorMessage ?? ''),
      SyncPhase.idle =>
        state.counts.hasWork
            ? (Icons.cloud_upload_outlined, 'جاهز للرفع', 'اضغط الزر عندما يتوفر الإنترنت')
            : (Icons.cloud_done_rounded, 'كل شيء مرفوع', 'لا توجد عمليات جديدة'),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.extraLarge)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: state.phase == SyncPhase.uploading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.ink),
                      )
                    : Icon(icon, color: AppColors.ink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.title.copyWith(color: Colors.white)),
                    Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textOnInkSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _CountBox(label: 'عمليات بانتظار الرفع', value: state.counts.operations),
              const SizedBox(width: 10),
              _CountBox(label: 'رسائل بانتظار الإرسال', value: state.counts.messages),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountBox extends StatelessWidget {
  const _CountBox({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.inkSoft, borderRadius: BorderRadius.circular(AppRadius.medium)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value', style: AppTextStyles.headline.copyWith(color: Colors.white)),
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textOnInkSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
