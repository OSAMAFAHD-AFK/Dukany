import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/floating_pill_button.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../manager/suppliers_list_cubit/suppliers_list_cubit.dart';
import 'widgets/supplier_form_sheet.dart';
import 'widgets/supplier_tile.dart';
import 'widgets/suppliers_total_banner.dart';

class SuppliersView extends StatelessWidget {
  const SuppliersView({super.key});

  Future<void> _addSupplier(BuildContext context) async {
    final supplier = await showSupplierFormSheet(context);
    if (supplier != null && context.mounted) {
      context.push(AppRouter.supplierDetailsPath(supplier.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الموردين وفواتير الجملة')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingPillButton(label: 'مورد جديد', onPressed: () => _addSupplier(context)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SearchField(
              hint: 'ابحث باسم الشركة أو المورد',
              onChanged: context.read<SuppliersListCubit>().search,
            ),
          ),
          Expanded(
            child: BlocBuilder<SuppliersListCubit, SuppliersListState>(
              builder: (context, state) {
                return switch (state) {
                  SuppliersListLoading() => const LoadingView(),
                  SuppliersListFailure(:final message) => ErrorView(
                    message: message,
                    onRetry: context.read<SuppliersListCubit>().loadSuppliers,
                  ),
                  SuppliersListLoaded(:final suppliers, :final query) when suppliers.isEmpty => EmptyStateView(
                    icon: query.isEmpty ? Icons.local_shipping_outlined : Icons.search_off_rounded,
                    title: query.isEmpty ? 'لا يوجد موردين بعد' : 'لا يوجد مورد بهذا الاسم',
                    message: query.isEmpty ? 'أضف شركة الجملة وصوّر فواتيرها' : null,
                  ),
                  SuppliersListLoaded(:final suppliers, :final totalDue) => ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                    itemCount: suppliers.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SuppliersTotalBanner(totalDue: totalDue, suppliersCount: suppliers.length);
                      }
                      final supplier = suppliers[index - 1];
                      return SupplierTile(
                        supplier: supplier,
                        onTap: () => context.push(AppRouter.supplierDetailsPath(supplier.id)),
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
