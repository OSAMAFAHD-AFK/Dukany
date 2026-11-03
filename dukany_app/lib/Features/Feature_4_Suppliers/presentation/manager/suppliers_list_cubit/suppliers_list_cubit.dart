import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/supplier_model.dart';
import '../../../data/repos/suppliers_repo.dart';

part 'suppliers_list_state.dart';

class SuppliersListCubit extends Cubit<SuppliersListState> {
  SuppliersListCubit(this._suppliersRepo) : super(const SuppliersListLoading()) {
    _changesSubscription = _suppliersRepo.changes.listen((_) => loadSuppliers());
  }

  final SuppliersRepo _suppliersRepo;
  late final StreamSubscription<void> _changesSubscription;
  String _query = '';

  Future<void> loadSuppliers() async {
    final result = await _suppliersRepo.getSuppliers(query: _query);
    if (isClosed) return;
    result.fold(
      (failure) => emit(SuppliersListFailure(failure.message)),
      (suppliers) => emit(SuppliersListLoaded(suppliers: suppliers, query: _query)),
    );
  }

  void search(String query) {
    _query = query;
    loadSuppliers();
  }

  @override
  Future<void> close() {
    _changesSubscription.cancel();
    return super.close();
  }
}
