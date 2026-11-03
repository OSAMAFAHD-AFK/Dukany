import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/customer_model.dart';
import '../../../data/repos/customers_repo.dart';

part 'customers_list_state.dart';

class CustomersListCubit extends Cubit<CustomersListState> {
  CustomersListCubit(this._customersRepo) : super(const CustomersListLoading()) {
    _changesSubscription = _customersRepo.changes.listen((_) => loadCustomers());
  }

  final CustomersRepo _customersRepo;
  late final StreamSubscription<void> _changesSubscription;
  String _query = '';

  Future<void> loadCustomers() async {
    final result = await _customersRepo.getCustomers(query: _query);
    if (isClosed) return;
    result.fold(
      (failure) => emit(CustomersListFailure(failure.message)),
      (customers) => emit(CustomersListLoaded(customers: customers, query: _query)),
    );
  }

  void search(String query) {
    _query = query;
    loadCustomers();
  }

  @override
  Future<void> close() {
    _changesSubscription.cancel();
    return super.close();
  }
}
