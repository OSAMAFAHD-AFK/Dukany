import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/functions/app_snack_bar.dart';
import '../../../../core/utils/functions/money_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../manager/add_supplier_invoice_cubit/add_supplier_invoice_cubit.dart';
import 'widgets/invoice_amount_form.dart';
import 'widgets/invoice_image_source_picker.dart';

class AddSupplierInvoiceView extends StatelessWidget {
  const AddSupplierInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddSupplierInvoiceCubit, AddSupplierInvoiceState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == AddSupplierInvoiceStatus.saved) {
          showAppSnackBar(
            context,
            'تم حفظ الفاتورة — المتبقي عليك ${formatMoneyWithCurrency(state.remainingAfterSave ?? 0)}',
          );
          context.pop();
        } else if (state.errorMessage != null && state.supplier != null) {
          showAppSnackBar(context, state.errorMessage!, isError: true);
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddSupplierInvoiceCubit>();
        return Scaffold(
          appBar: AppBar(title: Text(state.supplier == null ? 'فاتورة جديدة' : 'فاتورة ${state.supplier!.name}')),
          body: switch (state.status) {
            AddSupplierInvoiceStatus.loading => const LoadingView(),
            AddSupplierInvoiceStatus.failure when state.supplier == null => ErrorView(
              message: state.errorMessage ?? '',
              onRetry: cubit.loadSupplier,
            ),
            AddSupplierInvoiceStatus.choosingImage => InvoiceImageSourcePicker(
              onCamera: () => cubit.pickImage(fromCamera: true),
              onGallery: () => cubit.pickImage(fromCamera: false),
              onWithoutImage: cubit.continueWithoutImage,
            ),
            AddSupplierInvoiceStatus.scanning => const LoadingView(message: 'جاري قراءة إجمالي الفاتورة...'),
            _ => InvoiceAmountForm(
              imagePath: state.imagePath,
              scanResult: state.scanResult,
              isSaving: state.status == AddSupplierInvoiceStatus.saving,
              onRetake: cubit.retakeImage,
              onSave: (amountText, note) => cubit.save(amount: parseMoney(amountText), note: note),
            ),
          },
        );
      },
    );
  }
}
