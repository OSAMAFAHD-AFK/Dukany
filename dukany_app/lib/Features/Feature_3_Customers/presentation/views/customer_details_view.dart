import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/party_type.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/widgets/amount_input_sheet.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../data/models/customer_entry_model.dart';
import '../../data/models/customer_model.dart';
import '../manager/customer_details_cubit/customer_details_cubit.dart';
import 'widgets/customer_balance_card.dart';
import 'widgets/customer_entries_list.dart';
import 'widgets/customer_entry_details_sheet.dart';
import 'widgets/customer_form_sheet.dart';
import 'widgets/entry_saved_sheet.dart';

class CustomerDetailsView extends StatelessWidget {
  const CustomerDetailsView({super.key});

  Future<void> _receivePayment(BuildContext context, CustomerModel customer) async {
    final cubit = context.read<CustomerDetailsCubit>();
    final input = await showAmountInputSheet(
      context,
      title: 'استلام دفعة',
      subtitle: 'المبلغ الذي دفعه ${customer.name}',
      confirmLabel: 'حفظ التسديد',
      confirmVariant: CustomButtonVariant.success,
      suggestedAmount: customer.balance > 0 ? customer.balance : null,
    );
    if (input == null || !context.mounted) return;

    final outcome = await cubit.addPayment(amount: input.amount, note: input.note);
    if (!context.mounted) return;
    if (outcome.error != null) return showAppSnackBar(context, outcome.error!, isError: true);

    final sendNow = await showEntrySavedSheet(context, outcome.result!);
    if (!sendNow || !context.mounted) return;
    final error = await cubit.sendMessageNow(outcome.result!);
    if (error != null && context.mounted) showAppSnackBar(context, error, isError: true);
  }

  Future<void> _openEntry(BuildContext context, CustomerEntryModel entry) async {
    final cubit = context.read<CustomerDetailsCubit>();
    final wantsDelete = await showCustomerEntryDetailsSheet(context, entry);
    if (!wantsDelete || !context.mounted) return;
    final confirmed = await showConfirmDialog(
      context,
      title: 'حذف العملية؟',
      message: 'سيتم حذف هذه العملية وتعديل حساب الزبون. لا يمكن التراجع.',
      confirmLabel: 'حذف',
      isDanger: true,
    );
    if (!confirmed) return;
    final error = await cubit.deleteEntry(entry);
    if (context.mounted) showAppSnackBar(context, error ?? 'تم حذف العملية', isError: error != null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerDetailsCubit, CustomerDetailsState>(
      builder: (context, state) {
        final customer = state is CustomerDetailsLoaded ? state.customer : null;
        return Scaffold(
          appBar: AppBar(
            title: const Text('حساب الزبون'),
            actions: [
              if (customer != null)
                IconButton(
                  tooltip: 'تعديل البيانات',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => showCustomerFormSheet(context, editingCustomer: customer),
                ),
            ],
          ),
          body: switch (state) {
            CustomerDetailsLoading() => const LoadingView(),
            CustomerDetailsFailure(:final message) => ErrorView(
              message: message,
              onRetry: context.read<CustomerDetailsCubit>().loadDetails,
            ),
            CustomerDetailsLoaded(:final customer, :final entries) => CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  sliver: SliverList.list(
                    children: [
                      CustomerBalanceCard(customer: customer),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              label: 'تسجيل دين',
                              icon: Icons.add_shopping_cart_rounded,
                              onPressed: () => context.push(AppRouter.addCustomerDebtPath(customer.id)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomButton(
                              label: 'استلام دفعة',
                              icon: Icons.payments_outlined,
                              variant: CustomButtonVariant.success,
                              onPressed: () => _receivePayment(context, customer),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        label: 'كشف الحساب',
                        icon: Icons.receipt_long_outlined,
                        variant: CustomButtonVariant.soft,
                        onPressed: () => context.push(AppRouter.statementPath(PartyType.customer, customer.id)),
                      ),
                      const SizedBox(height: 22),
                      const Text('العمليات', style: AppTextStyles.title),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                CustomerEntriesList(entries: entries, onEntryTap: (entry) => _openEntry(context, entry)),
              ],
            ),
          },
        );
      },
    );
  }
}
