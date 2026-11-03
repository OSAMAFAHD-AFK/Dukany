import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../Feature_1_Auth/presentation/manager/admin_session_cubit/admin_session_cubit.dart';
import '../manager/shops_cubit/shops_cubit.dart';
import 'widgets/dashboard_top_bar.dart';
import 'widgets/shop_row_card.dart';
import 'widgets/shops_stats_row.dart';
import 'widgets/shops_toolbar.dart';

class ShopsDashboardView extends StatelessWidget {
  const ShopsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminSessionCubit, String?>(
      listener: (context, email) {
        if (email == null) context.go(AppRouter.kAdminLoginView);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: BlocBuilder<ShopsCubit, ShopsState>(
                builder: (context, state) {
                  final cubit = context.read<ShopsCubit>();
                  final visibleShops = state.visibleShops;
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        sliver: SliverList.list(
                          children: [
                            const DashboardTopBar(),
                            const SizedBox(height: 24),
                            ShopsStatsRow(state: state, onFilterTap: cubit.changeFilter),
                            const SizedBox(height: 20),
                            ShopsToolbar(state: state),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                      switch (state.status) {
                        ShopsStatus.loading => const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        ShopsStatus.failure => SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(state.errorMessage ?? '', style: AppTextStyles.body),
                                const SizedBox(height: 12),
                                CustomButton(
                                  label: 'إعادة المحاولة',
                                  icon: Icons.refresh_rounded,
                                  expand: false,
                                  onPressed: cubit.loadShops,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ShopsStatus.loaded when visibleShops.isEmpty => const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: Text('لا توجد بقالات مطابقة', style: AppTextStyles.caption)),
                        ),
                        ShopsStatus.loaded => SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                          sliver: SliverList.separated(
                            itemCount: visibleShops.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) => ShopRowCard(
                              shop: visibleShops[index],
                              isBusy: state.busyShopIds.contains(visibleShops[index].id),
                            ),
                          ),
                        ),
                      },
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
