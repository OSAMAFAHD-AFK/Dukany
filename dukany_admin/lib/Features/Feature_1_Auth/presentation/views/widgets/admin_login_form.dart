import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../manager/admin_login_cubit/admin_login_cubit.dart';

class AdminLoginForm extends StatefulWidget {
  const AdminLoginForm({super.key});

  @override
  State<AdminLoginForm> createState() => _AdminLoginFormState();
}

class _AdminLoginFormState extends State<AdminLoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() =>
      context.read<AdminLoginCubit>().login(email: _emailController.text, password: _passwordController.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.extraLarge)),
      child: AutofillGroup(
        child: Column(
          children: [
            CustomTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: 'admin@example.com',
              prefixIcon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              label: 'كلمة المرور',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            BlocBuilder<AdminLoginCubit, AdminLoginState>(
              builder: (context, state) => CustomButton(
                label: 'دخول',
                icon: Icons.login_rounded,
                isLoading: state is AdminLoginLoading,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
