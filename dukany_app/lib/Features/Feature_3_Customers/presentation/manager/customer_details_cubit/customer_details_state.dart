part of 'customer_details_cubit.dart';

sealed class CustomerDetailsState extends Equatable {
  const CustomerDetailsState();

  @override
  List<Object?> get props => [];
}

final class CustomerDetailsLoading extends CustomerDetailsState {
  const CustomerDetailsLoading();
}

final class CustomerDetailsLoaded extends CustomerDetailsState {
  const CustomerDetailsLoaded({required this.customer, required this.entries});

  final CustomerModel customer;
  final List<CustomerEntryModel> entries;

  @override
  List<Object?> get props => [customer, entries];
}

final class CustomerDetailsFailure extends CustomerDetailsState {
  const CustomerDetailsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
