import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/widgets/dukany_logo.dart';
import '../manager/login_cubit/login_cubit.dart';
import 'widgets/login_form.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) showAppSnackBar(context, state.message, isError: true);
        if (state is LoginSuccess) {
          context.go(state.session.canUseApp ? AppRouter.kRestoreDataView : AppRouter.kSubscriptionEndedView);
        }
      },
      child: const Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  DukanyLogo(size: 76),
                  SizedBox(height: 8),
                  Text('سجّل دخولك برقم جوال البقالة', style: AppTextStyles.caption),
                  SizedBox(height: 36),
                  LoginForm(),
                  SizedBox(height: 24),
                  Text(
                    'ليس لديك حساب؟ تواصل معنا لتفعيل اشتراك بقالتك',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
