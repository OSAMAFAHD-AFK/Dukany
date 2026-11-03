import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/app_router.dart';
import '../../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../../core/utils/functions/date_formatter.dart';
import '../../../../../core/utils/functions/phone_normalizer.dart';
import '../../../../../core/utils/service_locator.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../Feature_1_Auth/presentation/manager/shop_account_cubit/shop_account_cubit.dart';
import '../../../../Feature_5_Sync/presentation/manager/sync_badge_cubit/sync_badge_cubit.dart';

Future<void> showAccountSheet(BuildContext context) {
  final pendingOperations = context.read<SyncBadgeCubit>().state.operations;
  return showModalBottomSheet<void>(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) => getIt<ShopAccountCubit>(),
      child: AccountSheetBody(pendingOperations: pendingOperations),
    ),
  );
}

class AccountSheetBody extends StatelessWidget {
  const AccountSheetBody({super.key, required this.pendingOperations});

  final int pendingOperations;

  Future<void> _logout(BuildContext context) async {
    final hasPending = pendingOperations > 0;
    final confirmed = await showConfirmDialog(
      context,
      title: 'تسجيل الخروج؟',
      message: hasPending
          ? 'لديك $pendingOperations عملية لم تُرفع بعد وستُحذف من الجوال! ارفعها أولاً من زر الرفع.'
          : 'سيتم حذف البيانات من هذا الجوال، وتبقى محفوظة في السحابة وتعود عند الدخول مرة أخرى.',
      confirmLabel: 'خروج',
      isDanger: true,
    );
    if (confirmed && context.mounted) context.read<ShopAccountCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopAccountCubit, ShopAccountState>(
      listener: (context, state) {
        if (state.isLoggedOut) {
          context.go(AppRouter.kLoginView);
        } else if (state.message != null) {
          showAppSnackBar(context, state.message!);
        }
      },
      builder: (context, state) {
        final session = state.session;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session?.shopName ?? 'حسابي', style: AppTextStyles.headline),
                if (session != null) ...[
                  Text('${session.ownerName} • ${formatPhoneForDisplay(session.phone)}', style: AppTextStyles.caption),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: session.daysLeft <= 5 ? AppColors.warningSoft : AppColors.paidSoft,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          color: session.daysLeft <= 5 ? AppColors.warning : AppColors.paid,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'الاشتراك فعّال حتى ${formatDate(session.subscriptionEndsAt)}'
                            ' (متبقي ${session.daysLeft} يوم)',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                CustomButton(
                  label: 'تحديث حالة الاشتراك',
                  icon: Icons.refresh_rounded,
                  variant: CustomButtonVariant.outlined,
                  isLoading: state.isBusy,
                  onPressed: context.read<ShopAccountCubit>().checkSubscriptionAgain,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  label: 'تسجيل الخروج',
                  icon: Icons.logout_rounded,
                  variant: CustomButtonVariant.danger,
                  onPressed: state.isBusy ? null : () => _logout(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
