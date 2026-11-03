import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/supplier_entry_model.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/repos/suppliers_repo.dart';

part 'supplier_details_state.dart';

class SupplierDetailsCubit extends Cubit<SupplierDetailsState> {
  SupplierDetailsCubit(this._suppliersRepo, {required this.supplierId}) : super(const SupplierDetailsLoading()) {
    _changesSubscription = _suppliersRepo.changes.listen((_) => loadDetails());
  }

  final SuppliersRepo _suppliersRepo;
  final String supplierId;
  late final StreamSubscription<void> _changesSubscription;

  Future<void> loadDetails() async {
    final supplierResult = await _suppliersRepo.getSupplier(supplierId);
    final entriesResult = await _suppliersRepo.getEntries(supplierId);
    if (isClosed) return;
    supplierResult.fold(
      (failure) => emit(SupplierDetailsFailure(failure.message)),
      (supplier) => entriesResult.fold(
        (failure) => emit(SupplierDetailsFailure(failure.message)),
        (entries) => emit(SupplierDetailsLoaded(supplier: supplier, entries: entries)),
      ),
    );
  }

  /// Returns the remaining amount owed, or an Arabic error message.
  Future<({double? remaining, String? error})> addPayment({required double amount, String? note}) async {
    final current = state;
    if (current is! SupplierDetailsLoaded) return (remaining: null, error: 'انتظر تحميل البيانات');
    final result = await _suppliersRepo.addPayment(supplier: current.supplier, amount: amount, note: note);
    return result.fold(
      (failure) => (remaining: null, error: failure.message),
      (remaining) => (remaining: remaining, error: null),
    );
  }

  Future<String?> deleteEntry(SupplierEntryModel entry) async {
    final result = await _suppliersRepo.deleteEntry(entry);
    return result.fold((failure) => failure.message, (_) => null);
  }

  Future<({String? url, String? error})> getRemoteImageUrl(SupplierEntryModel entry) async {
    final result = await _suppliersRepo.getRemoteImageUrl(entry);
    return result.fold((failure) => (url: null, error: failure.message), (url) => (url: url, error: null));
  }

  @override
  Future<void> close() {
    _changesSubscription.cancel();
    return super.close();
  }
}
