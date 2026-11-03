import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/widgets/dukany_logo.dart';
import '../manager/splash_cubit/splash_cubit.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is! SplashDecided) return;
        context.go(switch (state.destination) {
          SplashDestination.login => AppRouter.kLoginView,
          SplashDestination.home => AppRouter.kHomeView,
          SplashDestination.subscriptionEnded => AppRouter.kSubscriptionEndedView,
        });
      },
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DukanyLogo(size: 88),
              SizedBox(height: 6),
              Text('دفتر بقالتك الذكي', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}
