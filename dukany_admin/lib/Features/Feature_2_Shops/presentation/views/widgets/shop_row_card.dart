import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../../core/utils/functions/date_formatter.dart';
import '../../../../../core/utils/functions/phone_normalizer.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../data/models/shop_model.dart';
import '../../manager/shops_cubit/shops_cubit.dart';
import 'extend_subscription_dialog.dart';
import 'reset_password_dialog.dart';
import 'shop_status_badge.dart';

class ShopRowCard extends StatelessWidget {
  const ShopRowCard({super.key, required this.shop, required this.isBusy});

  final ShopModel shop;
  final bool isBusy;

  Future<void> _run(BuildContext context, Future<String?> Function() action, String successMessage) async {
    final error = await action();
    if (context.mounted) showAppSnackBar(context, error ?? successMessage, isError: error != null);
  }

  Future<void> _extend(BuildContext context) async {
    final cubit = context.read<ShopsCubit>();
    final months = await showExtendSubscriptionDialog(context, shop);
    if (months == null || !context.mounted) return;
    await _run(context, () => cubit.extendSubscription(shop, months), 'تم تمديد اشتراك ${shop.name} $months شهر');
  }

  Future<void> _resetPassword(BuildContext context) async {
    final cubit = context.read<ShopsCubit>();
    final password = await showResetPasswordDialog(context, shop);
    if (password == null || !context.mounted) return;
    await _run(context, () => cubit.resetPassword(shop, password), 'تم تغيير كلمة المرور إلى: $password');
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ShopsCubit>();
    final daysLeft = shop.daysLeft;
    final subscriptionText = shop.subscriptionEndsAt.isAfter(DateTime.now())
        ? 'حتى ${formatDate(shop.subscriptionEndsAt)} • متبقي $daysLeft يوم'
        : 'انتهى في ${formatDate(shop.subscriptionEndsAt)}';

    final info = Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.fieldFill, borderRadius: BorderRadius.circular(AppRadius.medium)),
          child: Text(shop.name.characters.first, style: AppTextStyles.title),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(shop.name, style: AppTextStyles.subtitle, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  ShopStatusBadge(status: shop.status),
                ],
              ),
              Text(
                '${shop.ownerName} • ${formatPhoneForDisplay(shop.phone)}',
                style: AppTextStyles.caption,
                overflow: TextOverflow.ellipsis,
              ),
              Text(subscriptionText, style: AppTextStyles.caption.copyWith(color: AppColors.ink)),
            ],
          ),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isBusy)
          const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else
          Tooltip(
            message: shop.isActive ? 'إيقاف البقالة' : 'تفعيل البقالة',
            child: Switch(
              value: shop.isActive,
              activeTrackColor: AppColors.paid,
              onChanged: (value) => _run(
                context,
                () => cubit.setActive(shop, value),
                value ? 'تم تفعيل ${shop.name}' : 'تم إيقاف ${shop.name}',
              ),
            ),
          ),
        const SizedBox(width: 6),
        FilledButton.tonalIcon(
          onPressed: isBusy ? null : () => _extend(context),
          icon: const Icon(Icons.update_rounded, size: 18),
          label: const Text('تمديد'),
        ),
        PopupMenuButton<String>(
          tooltip: 'المزيد',
          onSelected: (value) {
            if (value == 'reset') _resetPassword(context);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'reset',
              child: ListTile(leading: Icon(Icons.key_rounded), title: Text('تغيير كلمة المرور')),
            ),
          ],
        ),
      ],
    );

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth > 720
            ? Row(
                children: [
                  Expanded(child: info),
                  actions,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  info,
                  const SizedBox(height: 10),
                  Align(alignment: AlignmentDirectional.centerEnd, child: actions),
                ],
              ),
      ),
    );
  }
}
