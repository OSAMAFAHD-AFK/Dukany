import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../manager/restore_data_cubit/restore_data_cubit.dart';

class RestoreDataView extends StatelessWidget {
  const RestoreDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RestoreDataCubit, RestoreDataState>(
      listener: (context, state) {
        if (state.status == RestoreDataStatus.done) context.go(AppRouter.kHomeView);
      },
      builder: (context, state) {
        final failed = state.status == RestoreDataStatus.failure;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                    child: failed
                        ? const Icon(Icons.cloud_off_rounded, size: 42, color: AppColors.debt)
                        : const Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(strokeWidth: 3)),
                  ),
                  const SizedBox(height: 22),
                  Text(failed ? 'تعذّر استرجاع البيانات' : 'جاري تجهيز حسابك', style: AppTextStyles.headline),
                  const SizedBox(height: 8),
                  Text(
                    failed ? state.errorMessage ?? '' : 'نسترجع بيانات بقالتك المحفوظة في السحابة',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  if (failed) ...[
                    CustomButton(
                      label: 'حاول مرة أخرى',
                      icon: Icons.refresh_rounded,
                      onPressed: context.read<RestoreDataCubit>().restore,
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      label: 'متابعة بدون استرجاع',
                      variant: CustomButtonVariant.outlined,
                      onPressed: () => context.go(AppRouter.kHomeView),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
