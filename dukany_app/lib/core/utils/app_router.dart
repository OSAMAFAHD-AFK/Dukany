import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../Features/Feature_1_Auth/presentation/manager/login_cubit/login_cubit.dart';
import '../../Features/Feature_1_Auth/presentation/manager/shop_account_cubit/shop_account_cubit.dart';
import '../../Features/Feature_1_Auth/presentation/manager/splash_cubit/splash_cubit.dart';
import '../../Features/Feature_1_Auth/presentation/views/login_view.dart';
import '../../Features/Feature_1_Auth/presentation/views/splash_view.dart';
import '../../Features/Feature_1_Auth/presentation/views/subscription_ended_view.dart';
import '../../Features/Feature_2_Home/presentation/manager/home_cubit/home_cubit.dart';
import '../../Features/Feature_2_Home/presentation/views/home_view.dart';
import '../../Features/Feature_3_Customers/presentation/manager/add_customer_debt_cubit/add_customer_debt_cubit.dart';
import '../../Features/Feature_3_Customers/presentation/manager/customer_details_cubit/customer_details_cubit.dart';
import '../../Features/Feature_3_Customers/presentation/manager/customers_list_cubit/customers_list_cubit.dart';
import '../../Features/Feature_3_Customers/presentation/views/add_customer_debt_view.dart';
import '../../Features/Feature_3_Customers/presentation/views/customer_details_view.dart';
import '../../Features/Feature_3_Customers/presentation/views/customers_view.dart';
import '../../Features/Feature_4_Suppliers/presentation/manager/add_supplier_invoice_cubit/add_supplier_invoice_cubit.dart';
import '../../Features/Feature_4_Suppliers/presentation/manager/supplier_details_cubit/supplier_details_cubit.dart';
import '../../Features/Feature_4_Suppliers/presentation/manager/suppliers_list_cubit/suppliers_list_cubit.dart';
import '../../Features/Feature_4_Suppliers/presentation/views/add_supplier_invoice_view.dart';
import '../../Features/Feature_4_Suppliers/presentation/views/supplier_details_view.dart';
import '../../Features/Feature_4_Suppliers/presentation/views/suppliers_view.dart';
import '../../Features/Feature_5_Sync/presentation/manager/restore_data_cubit/restore_data_cubit.dart';
import '../../Features/Feature_5_Sync/presentation/manager/sync_cubit/sync_cubit.dart';
import '../../Features/Feature_5_Sync/presentation/views/restore_data_view.dart';
import '../../Features/Feature_5_Sync/presentation/views/sync_view.dart';
import '../../Features/Feature_6_Statement/presentation/manager/statement_cubit/statement_cubit.dart';
import '../../Features/Feature_6_Statement/presentation/views/statement_view.dart';
import '../models/party_type.dart';
import 'service_locator.dart';

abstract class AppRouter {
  static const String kSplashView = '/';
  static const String kLoginView = '/login';
  static const String kSubscriptionEndedView = '/subscription-ended';
  static const String kRestoreDataView = '/restore';
  static const String kHomeView = '/home';
  static const String kCustomersView = '/customers';
  static const String kCustomerDetailsView = '/customers/:customerId';
  static const String kAddCustomerDebtView = '/customers/:customerId/add-debt';
  static const String kSuppliersView = '/suppliers';
  static const String kSupplierDetailsView = '/suppliers/:supplierId';
  static const String kAddSupplierInvoiceView = '/suppliers/:supplierId/add-invoice';
  static const String kSyncView = '/sync';
  static const String kStatementView = '/statement/:partyType/:partyId';

  static String customerDetailsPath(String customerId) => '/customers/$customerId';

  static String addCustomerDebtPath(String customerId) => '/customers/$customerId/add-debt';

  static String supplierDetailsPath(String supplierId) => '/suppliers/$supplierId';

  static String addSupplierInvoicePath(String supplierId) => '/suppliers/$supplierId/add-invoice';

  static String statementPath(PartyType partyType, String partyId) => '/statement/${partyType.name}/$partyId';

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: kSplashView,
        builder: (context, state) =>
            BlocProvider(create: (_) => SplashCubit(getIt())..decideStartDestination(), child: const SplashView()),
      ),
      GoRoute(
        path: kLoginView,
        builder: (context, state) => BlocProvider(create: (_) => LoginCubit(getIt()), child: const LoginView()),
      ),
      GoRoute(
        path: kSubscriptionEndedView,
        builder: (context, state) =>
            BlocProvider(create: (_) => getIt<ShopAccountCubit>(), child: const SubscriptionEndedView()),
      ),
      GoRoute(
        path: kRestoreDataView,
        builder: (context, state) =>
            BlocProvider(create: (_) => RestoreDataCubit(getIt())..restore(), child: const RestoreDataView()),
      ),
      GoRoute(
        path: kHomeView,
        builder: (context, state) =>
            BlocProvider(create: (_) => HomeCubit(getIt())..loadSummary(), child: const HomeView()),
      ),
      GoRoute(
        path: kCustomersView,
        builder: (context, state) =>
            BlocProvider(create: (_) => CustomersListCubit(getIt())..loadCustomers(), child: const CustomersView()),
      ),
      GoRoute(
        path: kCustomerDetailsView,
        builder: (context, state) => BlocProvider(
          create: (_) => CustomerDetailsCubit(getIt(), customerId: state.pathParameters['customerId']!)..loadDetails(),
          child: const CustomerDetailsView(),
        ),
      ),
      GoRoute(
        path: kAddCustomerDebtView,
        builder: (context, state) => BlocProvider(
          create: (_) => AddCustomerDebtCubit(getIt(), customerId: state.pathParameters['customerId']!)..loadCustomer(),
          child: const AddCustomerDebtView(),
        ),
      ),
      GoRoute(
        path: kSuppliersView,
        builder: (context, state) =>
            BlocProvider(create: (_) => SuppliersListCubit(getIt())..loadSuppliers(), child: const SuppliersView()),
      ),
      GoRoute(
        path: kSupplierDetailsView,
        builder: (context, state) => BlocProvider(
          create: (_) => SupplierDetailsCubit(getIt(), supplierId: state.pathParameters['supplierId']!)..loadDetails(),
          child: const SupplierDetailsView(),
        ),
      ),
      GoRoute(
        path: kAddSupplierInvoiceView,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              AddSupplierInvoiceCubit(getIt(), supplierId: state.pathParameters['supplierId']!)..loadSupplier(),
          child: const AddSupplierInvoiceView(),
        ),
      ),
      GoRoute(
        path: kSyncView,
        builder: (context, state) =>
            BlocProvider(create: (_) => SyncCubit(getIt())..loadQueue(), child: const SyncView()),
      ),
      GoRoute(
        path: kStatementView,
        builder: (context, state) => BlocProvider(
          create: (_) => StatementCubit(
            getIt(),
            partyType: PartyType.fromName(state.pathParameters['partyType']!),
            partyId: state.pathParameters['partyId']!,
          )..loadStatement(),
          child: const StatementView(),
        ),
      ),
    ],
  );
}
