import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/party_type.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../core/utils/functions/money_formatter.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/widgets/amount_input_sheet.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../data/models/supplier_entry_model.dart';
import '../../data/models/supplier_model.dart';
import '../manager/supplier_details_cubit/supplier_details_cubit.dart';
import 'widgets/supplier_balance_card.dart';
import 'widgets/supplier_entry_details_sheet.dart';
import 'widgets/supplier_entry_tile.dart';
import 'widgets/supplier_form_sheet.dart';

class SupplierDetailsView extends StatelessWidget {
  const SupplierDetailsView({super.key});

  Future<void> _payInstallment(BuildContext context, SupplierModel supplier) async {
    final cubit = context.read<SupplierDetailsCubit>();
    final input = await showAmountInputSheet(
      context,
      title: 'تسجيل دفعة',
      subtitle: 'المبلغ الذي سلّمته لـ ${supplier.name}',
      confirmLabel: 'حفظ الدفعة',
      confirmVariant: CustomButtonVariant.success,
      suggestedAmount: supplier.balance > 0 ? supplier.balance : null,
    );
    if (input == null || !context.mounted) return;
    final outcome = await cubit.addPayment(amount: input.amount, note: input.note);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      outcome.error ?? 'تم حفظ الدفعة — المتبقي ${formatMoneyWithCurrency(outcome.remaining!)}',
      isError: outcome.error != null,
    );
  }

  Future<void> _openEntry(BuildContext context, SupplierEntryModel entry) async {
    final cubit = context.read<SupplierDetailsCubit>();
    final wantsDelete = await showSupplierEntryDetailsSheet(context, entry, cubit.getRemoteImageUrl);
    if (!wantsDelete || !context.mounted) return;
    final confirmed = await showConfirmDialog(
      context,
      title: 'حذف العملية؟',
      message: 'سيتم حذف هذه العملية وتعديل حساب المورد.',
      confirmLabel: 'حذف',
      isDanger: true,
    );
    if (!confirmed) return;
    final error = await cubit.deleteEntry(entry);
    if (context.mounted) showAppSnackBar(context, error ?? 'تم حذف العملية', isError: error != null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupplierDetailsCubit, SupplierDetailsState>(
      builder: (context, state) {
        final supplier = state is SupplierDetailsLoaded ? state.supplier : null;
        return Scaffold(
          appBar: AppBar(
            title: const Text('حساب المورد'),
            actions: [
              if (supplier != null)
                IconButton(
                  tooltip: 'تعديل البيانات',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => showSupplierFormSheet(context, editingSupplier: supplier),
                ),
            ],
          ),
          body: switch (state) {
            SupplierDetailsLoading() => const LoadingView(),
            SupplierDetailsFailure(:final message) => ErrorView(
              message: message,
              onRetry: context.read<SupplierDetailsCubit>().loadDetails,
            ),
            SupplierDetailsLoaded(:final supplier, :final entries) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                SupplierBalanceCard(supplier: supplier),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'تصوير فاتورة',
                        icon: Icons.document_scanner_outlined,
                        onPressed: () => context.push(AppRouter.addSupplierInvoicePath(supplier.id)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        label: 'تسجيل دفعة',
                        icon: Icons.payments_outlined,
                        variant: CustomButtonVariant.success,
                        onPressed: () => _payInstallment(context, supplier),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomButton(
                  label: 'كشف الحساب',
                  icon: Icons.receipt_long_outlined,
                  variant: CustomButtonVariant.soft,
                  onPressed: () => context.push(AppRouter.statementPath(PartyType.supplier, supplier.id)),
                ),
                const SizedBox(height: 22),
                const Text('الفواتير والدفعات', style: AppTextStyles.title),
                const SizedBox(height: 10),
                if (entries.isEmpty)
                  const EmptyStateView(
                    icon: Icons.document_scanner_outlined,
                    title: 'لا توجد فواتير بعد',
                    message: 'صوّر فاتورة الجملة وسيُحفظ إجماليها وصورتها',
                  )
                else
                  for (final entry in entries) ...[
                    SupplierEntryTile(entry: entry, onTap: () => _openEntry(context, entry)),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          },
        );
      },
    );
  }
}
