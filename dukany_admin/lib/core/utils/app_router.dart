import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../Features/Feature_1_Auth/data/repos/admin_auth_repo.dart';
import '../../Features/Feature_1_Auth/presentation/manager/admin_login_cubit/admin_login_cubit.dart';
import '../../Features/Feature_1_Auth/presentation/manager/admin_session_cubit/admin_session_cubit.dart';
import '../../Features/Feature_1_Auth/presentation/views/admin_login_view.dart';
import '../../Features/Feature_2_Shops/presentation/manager/shops_cubit/shops_cubit.dart';
import '../../Features/Feature_2_Shops/presentation/views/shops_dashboard_view.dart';
import 'service_locator.dart';

abstract class AppRouter {
  static const String kShopsDashboardView = '/';
  static const String kAdminLoginView = '/login';

  static final GoRouter router = GoRouter(
    // Every navigation re-checks with the server that the user is an admin.
    // Even if this check were bypassed, RLS would return no shops.
    redirect: (context, state) async {
      final isAdmin = await getIt<AdminAuthRepo>().hasValidAdminSession();
      final goingToLogin = state.matchedLocation == kAdminLoginView;
      if (!isAdmin) return goingToLogin ? null : kAdminLoginView;
      return goingToLogin ? kShopsDashboardView : null;
    },
    routes: [
      GoRoute(
        path: kAdminLoginView,
        builder: (context, state) =>
            BlocProvider(create: (_) => AdminLoginCubit(getIt()), child: const AdminLoginView()),
      ),
      GoRoute(
        path: kShopsDashboardView,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AdminSessionCubit(getIt())),
            BlocProvider(create: (_) => ShopsCubit(getIt())..loadShops()),
          ],
          child: const ShopsDashboardView(),
        ),
      ),
    ],
  );
}
