import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Features/Feature_1_Auth/data/data_sources/admin_auth_remote_data_source.dart';
import '../../Features/Feature_1_Auth/data/repos/admin_auth_repo.dart';
import '../../Features/Feature_1_Auth/data/repos/admin_auth_repo_impl.dart';
import '../../Features/Feature_2_Shops/data/data_sources/shops_remote_data_source.dart';
import '../../Features/Feature_2_Shops/data/repos/shops_repo.dart';
import '../../Features/Feature_2_Shops/data/repos/shops_repo_impl.dart';
import '../../Features/Feature_2_Shops/presentation/manager/create_shop_cubit/create_shop_cubit.dart';
import 'api_service.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<ApiService>(() => ApiService(Supabase.instance.client));

  // Feature 1 — Auth
  getIt
    ..registerLazySingleton<AdminAuthRemoteDataSource>(() => AdminAuthRemoteDataSource(getIt()))
    ..registerLazySingleton<AdminAuthRepo>(() => AdminAuthRepoImpl(getIt()));

  // Feature 2 — Shops
  getIt
    ..registerLazySingleton<ShopsRemoteDataSource>(() => ShopsRemoteDataSource(getIt()))
    ..registerLazySingleton<ShopsRepo>(() => ShopsRepoImpl(getIt()))
    ..registerFactory<CreateShopCubit>(() => CreateShopCubit(getIt()));
}
