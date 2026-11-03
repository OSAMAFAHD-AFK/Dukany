import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../core/utils/functions/date_formatter.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../manager/shop_account_cubit/shop_account_cubit.dart';

/// Blocks the app while the subscription is suspended or expired.
/// Data stays safe on the phone and in Supabase until it is renewed.
class SubscriptionEndedView extends StatelessWidget {
  const SubscriptionEndedView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopAccountCubit, ShopAccountState>(
      listener: (context, state) {
        if (state.isLoggedOut) return context.go(AppRouter.kLoginView);
        if (state.session?.canUseApp == true) return context.go(AppRouter.kHomeView);
        if (state.message != null) showAppSnackBar(context, state.message!, isError: true);
      },
      builder: (context, state) {
        final session = state.session;
        final cubit = context.read<ShopAccountCubit>();
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(color: AppColors.debtSoft, shape: BoxShape.circle),
                    child: const Icon(Icons.lock_clock_outlined, size: 46, color: AppColors.debt),
                  ),
                  const SizedBox(height: 22),
                  const Text('الاشتراك موقوف', style: AppTextStyles.headline),
                  const SizedBox(height: 8),
                  Text(
                    session == null
                        ? 'تواصل معنا لتجديد اشتراك بقالتك'
                        : session.isActive
                        ? 'انتهى اشتراك "${session.shopName}" بتاريخ ${formatDate(session.subscriptionEndsAt)}'
                        : 'تم إيقاف اشتراك "${session.shopName}" مؤقتاً',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'بياناتك محفوظة ولن تضيع. بعد التجديد اضغط "تحقق مرة أخرى"',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  CustomButton(
                    label: 'تحقق مرة أخرى',
                    icon: Icons.refresh_rounded,
                    isLoading: state.isBusy,
                    onPressed: cubit.checkSubscriptionAgain,
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    label: 'تسجيل الخروج',
                    variant: CustomButtonVariant.outlined,
                    onPressed: state.isBusy ? null : cubit.logout,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
