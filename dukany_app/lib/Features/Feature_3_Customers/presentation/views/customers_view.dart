import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/floating_pill_button.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../manager/customers_list_cubit/customers_list_cubit.dart';
import 'widgets/customer_form_sheet.dart';
import 'widgets/customer_tile.dart';
import 'widgets/customers_total_banner.dart';

class CustomersView extends StatelessWidget {
  const CustomersView({super.key});

  Future<void> _addCustomer(BuildContext context) async {
    final customer = await showCustomerFormSheet(context);
    if (customer != null && context.mounted) {
      context.push(AppRouter.customerDetailsPath(customer.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الزبائن (الدفتر)')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingPillButton(label: 'زبون جديد', onPressed: () => _addCustomer(context)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SearchField(hint: 'ابحث بالاسم أو الرقم', onChanged: context.read<CustomersListCubit>().search),
          ),
          Expanded(
            child: BlocBuilder<CustomersListCubit, CustomersListState>(
              builder: (context, state) {
                return switch (state) {
                  CustomersListLoading() => const LoadingView(),
                  CustomersListFailure(:final message) => ErrorView(
                    message: message,
                    onRetry: context.read<CustomersListCubit>().loadCustomers,
                  ),
                  CustomersListLoaded(:final customers, :final query) when customers.isEmpty => EmptyStateView(
                    icon: query.isEmpty ? Icons.menu_book_rounded : Icons.search_off_rounded,
                    title: query.isEmpty ? 'الدفتر فاضي' : 'لا يوجد زبون بهذا الاسم',
                    message: query.isEmpty ? 'أضف أول زبون وابدأ تسجيل حسابه' : null,
                  ),
                  CustomersListLoaded(:final customers) => ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                    itemCount: customers.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return CustomersTotalBanner(totalOwed: state.totalOwed, customersCount: customers.length);
                      }
                      final customer = customers[index - 1];
                      return CustomerTile(
                        customer: customer,
                        onTap: () => context.push(AppRouter.customerDetailsPath(customer.id)),
                      );
                    },
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
