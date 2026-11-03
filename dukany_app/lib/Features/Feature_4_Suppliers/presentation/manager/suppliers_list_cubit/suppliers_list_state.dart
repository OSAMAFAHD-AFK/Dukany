part of 'suppliers_list_cubit.dart';

sealed class SuppliersListState extends Equatable {
  const SuppliersListState();

  @override
  List<Object?> get props => [];
}

final class SuppliersListLoading extends SuppliersListState {
  const SuppliersListLoading();
}

final class SuppliersListLoaded extends SuppliersListState {
  const SuppliersListLoaded({required this.suppliers, required this.query});

  final List<SupplierModel> suppliers;
  final String query;

  double get totalDue =>
      suppliers.fold<double>(0, (sum, supplier) => supplier.balance > 0 ? sum + supplier.balance : sum);

  @override
  List<Object?> get props => [suppliers, query];
}

final class SuppliersListFailure extends SuppliersListState {
  const SuppliersListFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
