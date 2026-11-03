import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/invoice_scan_result_model.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/repos/suppliers_repo.dart';

part 'add_supplier_invoice_state.dart';

/// Photo → OCR suggests the total → owner confirms → saved.
class AddSupplierInvoiceCubit extends Cubit<AddSupplierInvoiceState> {
  AddSupplierInvoiceCubit(this._suppliersRepo, {required this.supplierId}) : super(const AddSupplierInvoiceState());

  final SuppliersRepo _suppliersRepo;
  final String supplierId;

  Future<void> loadSupplier() async {
    final result = await _suppliersRepo.getSupplier(supplierId);
    result.fold(
      (failure) => emit(state.copyWith(status: AddSupplierInvoiceStatus.failure, errorMessage: failure.message)),
      (supplier) => emit(state.copyWith(status: AddSupplierInvoiceStatus.choosingImage, supplier: supplier)),
    );
  }

  Future<void> pickImage({required bool fromCamera}) async {
    final picked = await _suppliersRepo.pickInvoiceImage(fromCamera: fromCamera);
    await picked.fold(
      (failure) async =>
          emit(state.copyWith(status: AddSupplierInvoiceStatus.choosingImage, errorMessage: failure.message)),
      (path) async {
        if (path == null) return; // cancelled
        emit(state.copyWith(status: AddSupplierInvoiceStatus.scanning, imagePath: path));
        final scan = await _suppliersRepo.scanInvoiceTotal(path);
        emit(
          state.copyWith(
            status: AddSupplierInvoiceStatus.ready,
            scanResult: scan.getOrElse(() => InvoiceScanResultModel.empty),
          ),
        );
      },
    );
  }

  void continueWithoutImage() => emit(
    state.copyWith(status: AddSupplierInvoiceStatus.ready, clearImage: true, scanResult: InvoiceScanResultModel.empty),
  );

  void retakeImage() => emit(
    state.copyWith(
      status: AddSupplierInvoiceStatus.choosingImage,
      clearImage: true,
      scanResult: InvoiceScanResultModel.empty,
    ),
  );

  Future<void> save({required double? amount, String? note}) async {
    final supplier = state.supplier;
    if (supplier == null || state.status == AddSupplierInvoiceStatus.saving) return;
    if (amount == null) {
      emit(state.copyWith(status: AddSupplierInvoiceStatus.failure, errorMessage: 'اكتب إجمالي الفاتورة'));
      return;
    }
    emit(state.copyWith(status: AddSupplierInvoiceStatus.saving));
    final result = await _suppliersRepo.addInvoice(
      supplier: supplier,
      amount: amount,
      temporaryImagePath: state.imagePath,
      note: note,
    );
    result.fold(
      (failure) => emit(state.copyWith(status: AddSupplierInvoiceStatus.failure, errorMessage: failure.message)),
      (remaining) => emit(state.copyWith(status: AddSupplierInvoiceStatus.saved, remainingAfterSave: remaining)),
    );
  }
}
