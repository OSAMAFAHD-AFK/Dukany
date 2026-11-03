part of 'supplier_details_cubit.dart';

sealed class SupplierDetailsState extends Equatable {
  const SupplierDetailsState();

  @override
  List<Object?> get props => [];
}

final class SupplierDetailsLoading extends SupplierDetailsState {
  const SupplierDetailsLoading();
}

final class SupplierDetailsLoaded extends SupplierDetailsState {
  const SupplierDetailsLoaded({required this.supplier, required this.entries});

  final SupplierModel supplier;
  final List<SupplierEntryModel> entries;

  @override
  List<Object?> get props => [supplier, entries];
}

final class SupplierDetailsFailure extends SupplierDetailsState {
  const SupplierDetailsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
