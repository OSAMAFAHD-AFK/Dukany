import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/customer_model.dart';
import '../../../data/repos/customers_repo.dart';

part 'customer_form_state.dart';

/// Add a new customer, or edit [editingCustomer] when given.
class CustomerFormCubit extends Cubit<CustomerFormState> {
  CustomerFormCubit(this._customersRepo, {this.editingCustomer}) : super(const CustomerFormState());

  final CustomersRepo _customersRepo;
  final CustomerModel? editingCustomer;

  bool get isEditing => editingCustomer != null;

  Future<void> save({required String name, String? phone}) async {
    emit(const CustomerFormState(status: CustomerFormStatus.saving));
    final result = isEditing
        ? await _customersRepo.updateCustomer(editingCustomer!, name: name, phone: phone)
        : await _customersRepo.addCustomer(name: name, phone: phone);
    result.fold(
      (failure) => emit(CustomerFormState(status: CustomerFormStatus.failure, errorMessage: failure.message)),
      (customer) => emit(CustomerFormState(status: CustomerFormStatus.success, savedCustomer: customer)),
    );
  }
}
