import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/models/party_type.dart';
import '../../../../../core/utils/app_router.dart';
import '../../../../../core/utils/functions/date_formatter.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/amount_text.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/party_avatar.dart';
import '../../../../../core/widgets/sync_state_icon.dart';
import '../../../data/models/recent_activity_model.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key, required this.activities});

  final List<RecentActivityModel> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const AppCard(
        child: Text(
          'لا توجد عمليات بعد. ابدأ من "الزبائن" وسجّل أول دين.',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      );
    }
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          for (var index = 0; index < activities.length; index++) ...[
            if (index > 0) const Divider(),
            _ActivityRow(activity: activities[index]),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final RecentActivityModel activity;

  @override
  Widget build(BuildContext context) {
    final isIncrease =
        activity.kind == RecentActivityKind.customerDebt || activity.kind == RecentActivityKind.supplierInvoice;
    final color = switch (activity.kind) {
      RecentActivityKind.customerDebt => AppColors.debt,
      RecentActivityKind.customerPayment => AppColors.paid,
      RecentActivityKind.supplierInvoice => AppColors.ink,
      RecentActivityKind.supplierPayment => AppColors.paid,
    };

    return InkWell(
      onTap: () => context.push(
        activity.partyType == PartyType.customer
            ? AppRouter.customerDetailsPath(activity.partyId)
            : AppRouter.supplierDetailsPath(activity.partyId),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            PartyAvatar(name: activity.partyName, size: 40, dark: activity.partyType == PartyType.supplier),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.partyName,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        '${activity.label} • ${formatRelativeDay(activity.createdAt)}',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(width: 6),
                      SyncStateIcon(isSynced: activity.isSynced),
                    ],
                  ),
                ],
              ),
            ),
            AmountText(amount: activity.amount, color: color, prefix: isIncrease ? '+' : '−', fontSize: 15),
          ],
        ),
      ),
    );
  }
}
