part of 'customers_list_cubit.dart';

sealed class CustomersListState extends Equatable {
  const CustomersListState();

  @override
  List<Object?> get props => [];
}

final class CustomersListLoading extends CustomersListState {
  const CustomersListLoading();
}

final class CustomersListLoaded extends CustomersListState {
  const CustomersListLoaded({required this.customers, required this.query});

  final List<CustomerModel> customers;
  final String query;

  double get totalOwed =>
      customers.fold<double>(0, (sum, customer) => customer.balance > 0 ? sum + customer.balance : sum);

  @override
  List<Object?> get props => [customers, query];
}

final class CustomersListFailure extends CustomersListState {
  const CustomersListFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
