import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/customer_entry_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/saved_entry_result_model.dart';
import '../../../data/repos/customers_repo.dart';

part 'customer_details_state.dart';

class CustomerDetailsCubit extends Cubit<CustomerDetailsState> {
  CustomerDetailsCubit(this._customersRepo, {required this.customerId}) : super(const CustomerDetailsLoading()) {
    _changesSubscription = _customersRepo.changes.listen((_) => loadDetails());
  }

  final CustomersRepo _customersRepo;
  final String customerId;
  late final StreamSubscription<void> _changesSubscription;

  Future<void> loadDetails() async {
    final customerResult = await _customersRepo.getCustomer(customerId);
    final entriesResult = await _customersRepo.getEntries(customerId);
    if (isClosed) return;
    customerResult.fold(
      (failure) => emit(CustomerDetailsFailure(failure.message)),
      (customer) => entriesResult.fold(
        (failure) => emit(CustomerDetailsFailure(failure.message)),
        (entries) => emit(CustomerDetailsLoaded(customer: customer, entries: entries)),
      ),
    );
  }

  /// Returns the saved result, or an Arabic error message.
  Future<({SavedEntryResultModel? result, String? error})> addPayment({required double amount, String? note}) async {
    final current = state;
    if (current is! CustomerDetailsLoaded) return (result: null, error: 'انتظر تحميل البيانات');
    final result = await _customersRepo.addPayment(customer: current.customer, amount: amount, note: note);
    return result.fold((failure) => (result: null, error: failure.message), (saved) => (result: saved, error: null));
  }

  Future<String?> sendMessageNow(SavedEntryResultModel saved) async {
    final result = await _customersRepo.sendQueuedMessageNow(saved);
    return result.fold((failure) => failure.message, (_) => null);
  }

  Future<String?> deleteEntry(CustomerEntryModel entry) async {
    final result = await _customersRepo.deleteEntry(entry);
    return result.fold((failure) => failure.message, (_) => null);
  }

  @override
  Future<void> close() {
    _changesSubscription.cancel();
    return super.close();
  }
}
