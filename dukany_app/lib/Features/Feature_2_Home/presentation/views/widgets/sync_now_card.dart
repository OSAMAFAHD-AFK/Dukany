import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/app_router.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../Feature_5_Sync/data/models/pending_counts_model.dart';
import '../../../../Feature_5_Sync/presentation/manager/sync_badge_cubit/sync_badge_cubit.dart';

/// The main "upload & send WhatsApp" button with the pending-tasks badge.
class SyncNowCard extends StatelessWidget {
  const SyncNowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBadgeCubit, PendingCountsModel>(
      builder: (context, counts) {
        final hasWork = counts.hasWork;
        return AppCard(
          onTap: () => context.push(AppRouter.kSyncView),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasWork ? AppColors.warningSoft : AppColors.paidSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasWork ? Icons.cloud_upload_outlined : Icons.cloud_done_rounded,
                  color: hasWork ? AppColors.warning : AppColors.paid,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hasWork ? 'رفع البيانات وإرسال الرسائل' : 'كل شيء مرفوع ومرسل', style: AppTextStyles.subtitle),
                    Text(
                      hasWork
                          ? '${counts.operations} عملية • ${counts.messages} رسالة واتساب'
                          : 'بياناتك محفوظة في السحابة',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              _UploadPill(badgeCount: counts.badgeCount),
            ],
          ),
        );
      },
    );
  }
}

class _UploadPill extends StatelessWidget {
  const _UploadPill({required this.badgeCount});

  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(100)),
          child: const Icon(Icons.sync_rounded, color: Colors.white),
        ),
        if (badgeCount > 0)
          PositionedDirectional(
            top: -6,
            start: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: AppTextStyles.caption.copyWith(color: AppColors.ink, fontWeight: FontWeight.w700, height: 1.2),
              ),
            ),
          ),
      ],
    );
  }
}
