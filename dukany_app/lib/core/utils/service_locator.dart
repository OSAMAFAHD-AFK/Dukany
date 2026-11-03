import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Features/Feature_1_Auth/data/data_sources/auth_remote_data_source.dart';
import '../../Features/Feature_1_Auth/data/repos/auth_repo.dart';
import '../../Features/Feature_1_Auth/data/repos/auth_repo_impl.dart';
import '../../Features/Feature_1_Auth/presentation/manager/shop_account_cubit/shop_account_cubit.dart';
import '../../Features/Feature_2_Home/data/data_sources/home_local_data_source.dart';
import '../../Features/Feature_2_Home/data/repos/home_repo.dart';
import '../../Features/Feature_2_Home/data/repos/home_repo_impl.dart';
import '../../Features/Feature_3_Customers/data/data_sources/customers_local_data_source.dart';
import '../../Features/Feature_3_Customers/data/repos/customers_repo.dart';
import '../../Features/Feature_3_Customers/data/repos/customers_repo_impl.dart';
import '../../Features/Feature_4_Suppliers/data/data_sources/invoice_image_data_source.dart';
import '../../Features/Feature_4_Suppliers/data/data_sources/invoice_text_recognition_data_source.dart';
import '../../Features/Feature_4_Suppliers/data/data_sources/suppliers_local_data_source.dart';
import '../../Features/Feature_4_Suppliers/data/repos/suppliers_repo.dart';
import '../../Features/Feature_4_Suppliers/data/repos/suppliers_repo_impl.dart';
import '../../Features/Feature_5_Sync/data/data_sources/sync_local_data_source.dart';
import '../../Features/Feature_5_Sync/data/data_sources/sync_remote_data_source.dart';
import '../../Features/Feature_5_Sync/data/repos/sync_repo.dart';
import '../../Features/Feature_5_Sync/data/repos/sync_repo_impl.dart';
import '../../Features/Feature_6_Statement/data/data_sources/statement_local_data_source.dart';
import '../../Features/Feature_6_Statement/data/data_sources/statement_pdf_generator.dart';
import '../../Features/Feature_6_Statement/data/repos/statement_repo.dart';
import '../../Features/Feature_6_Statement/data/repos/statement_repo_impl.dart';
import 'api_service.dart';
import 'local_database_service.dart';
import 'shop_session_storage.dart';

final GetIt getIt = GetIt.instance;

/// Call once in main() after Supabase.initialize().
Future<void> setupServiceLocator() async {
  // Core
  final localDatabase = LocalDatabaseService();
  await localDatabase.init();
  getIt
    ..registerSingleton<LocalDatabaseService>(localDatabase)
    ..registerSingleton<SharedPreferences>(await SharedPreferences.getInstance())
    ..registerLazySingleton<ApiService>(() => ApiService(Supabase.instance.client))
    ..registerLazySingleton<ShopSessionStorage>(() => ShopSessionStorage(getIt()));

  // Feature 1 — Auth
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(getIt()))
    ..registerLazySingleton<AuthRepo>(() => AuthRepoImpl(getIt(), getIt(), getIt()))
    ..registerFactory<ShopAccountCubit>(() => ShopAccountCubit(getIt()));

  // Feature 2 — Home
  getIt
    ..registerLazySingleton<HomeLocalDataSource>(() => HomeLocalDataSource(getIt()))
    ..registerLazySingleton<HomeRepo>(() => HomeRepoImpl(getIt()));

  // Feature 3 — Customers
  getIt
    ..registerLazySingleton<CustomersLocalDataSource>(() => CustomersLocalDataSource(getIt()))
    ..registerLazySingleton<CustomersRepo>(() => CustomersRepoImpl(getIt(), getIt()));

  // Feature 4 — Suppliers
  getIt
    ..registerLazySingleton<SuppliersLocalDataSource>(() => SuppliersLocalDataSource(getIt()))
    ..registerLazySingleton<InvoiceImageDataSource>(() => InvoiceImageDataSource(ImagePicker(), getIt()))
    ..registerLazySingleton<InvoiceTextRecognitionDataSource>(() => InvoiceTextRecognitionDataSource())
    ..registerLazySingleton<SuppliersRepo>(() => SuppliersRepoImpl(getIt(), getIt(), getIt()));

  // Feature 5 — Sync
  getIt
    ..registerLazySingleton<SyncLocalDataSource>(() => SyncLocalDataSource(getIt()))
    ..registerLazySingleton<SyncRemoteDataSource>(() => SyncRemoteDataSource(getIt()))
    ..registerLazySingleton<SyncRepo>(() => SyncRepoImpl(getIt(), getIt(), getIt()));

  // Feature 6 — Statement
  getIt
    ..registerLazySingleton<StatementLocalDataSource>(() => StatementLocalDataSource(getIt()))
    ..registerLazySingleton<StatementPdfGenerator>(() => StatementPdfGenerator())
    ..registerLazySingleton<StatementRepo>(() => StatementRepoImpl(getIt(), getIt(), getIt()));
}
