import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../manager/add_customer_debt_cubit/add_customer_debt_cubit.dart';
import 'widgets/debt_items_editor.dart';
import 'widgets/debt_total_bar.dart';
import 'widgets/entry_saved_sheet.dart';

class AddCustomerDebtView extends StatelessWidget {
  const AddCustomerDebtView({super.key});

  Future<void> _onSaved(BuildContext context, AddCustomerDebtState state) async {
    final cubit = context.read<AddCustomerDebtCubit>();
    final sendNow = await showEntrySavedSheet(context, state.savedResult!);
    if (sendNow) {
      final error = await cubit.sendMessageNow();
      if (error != null && context.mounted) showAppSnackBar(context, error, isError: true);
    }
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCustomerDebtCubit, AddCustomerDebtState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddCustomerDebtStatus.saved) {
          _onSaved(context, state);
        } else if (state.status == AddCustomerDebtStatus.failure && state.customer != null) {
          showAppSnackBar(context, state.errorMessage!, isError: true);
        }
      },
      builder: (context, state) {
        final customer = state.customer;
        return Scaffold(
          appBar: AppBar(title: Text(customer == null ? 'تسجيل دين' : 'دين على ${customer.name}')),
          bottomNavigationBar: customer == null
              ? null
              : DebtTotalBar(
                  total: state.total,
                  itemsCount: state.filledLinesCount,
                  isSaving: state.status == AddCustomerDebtStatus.saving,
                  onSave: context.read<AddCustomerDebtCubit>().save,
                ),
          body: switch (state.status) {
            AddCustomerDebtStatus.loading => const LoadingView(),
            AddCustomerDebtStatus.failure when customer == null => ErrorView(
              message: state.errorMessage ?? '',
              onRetry: context.read<AddCustomerDebtCubit>().loadCustomer,
            ),
            _ => DebtItemsEditor(
              frequentItemNames: state.frequentItemNames,
              onLinesChanged: context.read<AddCustomerDebtCubit>().updateLines,
              onNoteChanged: context.read<AddCustomerDebtCubit>().updateNote,
            ),
          },
        );
      },
    );
  }
}
