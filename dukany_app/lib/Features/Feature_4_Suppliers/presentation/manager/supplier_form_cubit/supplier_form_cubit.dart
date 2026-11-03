import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/supplier_model.dart';
import '../../../data/repos/suppliers_repo.dart';

part 'supplier_form_state.dart';

/// Add a new supplier, or edit [editingSupplier] when given.
class SupplierFormCubit extends Cubit<SupplierFormState> {
  SupplierFormCubit(this._suppliersRepo, {this.editingSupplier}) : super(const SupplierFormState());

  final SuppliersRepo _suppliersRepo;
  final SupplierModel? editingSupplier;

  Future<void> save({required String name, String? phone}) async {
    emit(const SupplierFormState(status: SupplierFormStatus.saving));
    final result = editingSupplier != null
        ? await _suppliersRepo.updateSupplier(editingSupplier!, name: name, phone: phone)
        : await _suppliersRepo.addSupplier(name: name, phone: phone);
    result.fold(
      (failure) => emit(SupplierFormState(status: SupplierFormStatus.failure, errorMessage: failure.message)),
      (supplier) => emit(SupplierFormState(status: SupplierFormStatus.success, savedSupplier: supplier)),
    );
  }
}
