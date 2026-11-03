part of 'supplier_form_cubit.dart';

enum SupplierFormStatus { initial, saving, success, failure }

class SupplierFormState extends Equatable {
  const SupplierFormState({this.status = SupplierFormStatus.initial, this.savedSupplier, this.errorMessage});

  final SupplierFormStatus status;
  final SupplierModel? savedSupplier;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, savedSupplier, errorMessage];
}
