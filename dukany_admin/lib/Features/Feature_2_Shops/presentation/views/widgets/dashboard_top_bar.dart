import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../../core/widgets/dukany_logo.dart';
import '../../../../Feature_1_Auth/presentation/manager/admin_session_cubit/admin_session_cubit.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AdminSessionCubit>().state;
    return Row(
      children: [
        const DukanyLogo(size: 48, showName: false),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('لوحة تحكم دُكاني', style: AppTextStyles.headline),
              Text('إدارة البقالات والاشتراكات الشهرية', style: AppTextStyles.caption),
            ],
          ),
        ),
        if (email != null && MediaQuery.sizeOf(context).width > 640)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Text(email, style: AppTextStyles.caption, textDirection: TextDirection.ltr),
          ),
        Material(
          color: AppColors.surface,
          shape: const StadiumBorder(),
          child: TextButton.icon(
            onPressed: context.read<AdminSessionCubit>().logout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('خروج'),
            style: TextButton.styleFrom(foregroundColor: AppColors.ink, padding: const EdgeInsets.all(14)),
          ),
        ),
      ],
    );
  }
}
