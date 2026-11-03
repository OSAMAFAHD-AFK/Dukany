part of 'customer_form_cubit.dart';

enum CustomerFormStatus { initial, saving, success, failure }

class CustomerFormState extends Equatable {
  const CustomerFormState({this.status = CustomerFormStatus.initial, this.savedCustomer, this.errorMessage});

  final CustomerFormStatus status;
  final CustomerModel? savedCustomer;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, savedCustomer, errorMessage];
}
