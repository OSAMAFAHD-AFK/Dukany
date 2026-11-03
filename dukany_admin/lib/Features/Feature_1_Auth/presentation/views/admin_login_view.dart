import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/widgets/dukany_logo.dart';
import '../manager/admin_login_cubit/admin_login_cubit.dart';
import 'widgets/admin_login_form.dart';

class AdminLoginView extends StatelessWidget {
  const AdminLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminLoginCubit, AdminLoginState>(
      listener: (context, state) {
        if (state is AdminLoginFailure) showAppSnackBar(context, state.message, isError: true);
        if (state is AdminLoginSuccess) context.go(AppRouter.kShopsDashboardView);
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const Column(
                children: [
                  DukanyLogo(size: 72),
                  SizedBox(height: 6),
                  Text('لوحة تحكم المشرف — إدارة اشتراكات البقالات', style: AppTextStyles.caption),
                  SizedBox(height: 32),
                  AdminLoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
