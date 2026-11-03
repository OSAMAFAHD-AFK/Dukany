import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/functions/money_formatter.dart';
import '../../../../core/utils/shop_session_storage.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../manager/home_cubit/home_cubit.dart';
import 'widgets/account_sheet.dart';
import 'widgets/balances_hero_card.dart';
import 'widgets/home_header.dart';
import 'widgets/home_section_tile.dart';
import 'widgets/recent_activity_list.dart';
import 'widgets/sync_now_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final shopName = getIt<ShopSessionStorage>().shopName;
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeLoading() => const LoadingView(),
              HomeFailure(:final message) => ErrorView(
                message: message,
                onRetry: context.read<HomeCubit>().loadSummary,
              ),
              HomeLoaded(:final summary) => RefreshIndicator(
                onRefresh: context.read<HomeCubit>().loadSummary,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    HomeHeader(shopName: shopName, onAccountTap: () => showAccountSheet(context)),
                    const SizedBox(height: 18),
                    BalancesHeroCard(summary: summary),
                    const SizedBox(height: 12),
                    const SyncNowCard(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: HomeSectionTile(
                            icon: Icons.menu_book_rounded,
                            title: 'الزبائن',
                            subtitle: '${summary.customersCount} حساب',
                            onTap: () => context.push(AppRouter.kCustomersView),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: HomeSectionTile(
                            icon: Icons.local_shipping_outlined,
                            title: 'الموردين',
                            subtitle: 'عليك ${formatMoney(summary.suppliersDue)}',
                            onTap: () => context.push(AppRouter.kSuppliersView),
                            dark: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('آخر العمليات', style: AppTextStyles.title),
                    const SizedBox(height: 10),
                    RecentActivityList(activities: summary.recentActivity),
                  ],
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}
