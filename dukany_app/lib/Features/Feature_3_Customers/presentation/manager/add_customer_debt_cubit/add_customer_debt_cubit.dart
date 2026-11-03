import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/functions/money_formatter.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/entry_item_model.dart';
import '../../../data/models/saved_entry_result_model.dart';
import '../../../data/repos/customers_repo.dart';

part 'add_customer_debt_state.dart';

class AddCustomerDebtCubit extends Cubit<AddCustomerDebtState> {
  AddCustomerDebtCubit(this._customersRepo, {required this.customerId}) : super(const AddCustomerDebtState());

  final CustomersRepo _customersRepo;
  final String customerId;

  Future<void> loadCustomer() async {
    final customerResult = await _customersRepo.getCustomer(customerId);
    final frequentResult = await _customersRepo.getFrequentItemNames();
    customerResult.fold(
      (failure) => emit(state.copyWith(status: AddCustomerDebtStatus.failure, errorMessage: failure.message)),
      (customer) => emit(
        state.copyWith(
          status: AddCustomerDebtStatus.ready,
          customer: customer,
          frequentItemNames: frequentResult.getOrElse(() => const []),
        ),
      ),
    );
  }

  void updateLines(List<DebtLineInput> lines) =>
      emit(state.copyWith(lines: lines, status: AddCustomerDebtStatus.ready));

  void updateNote(String note) => emit(state.copyWith(note: note, status: AddCustomerDebtStatus.ready));

  Future<void> save() async {
    final customer = state.customer;
    if (customer == null || state.status == AddCustomerDebtStatus.saving) return;

    final validationError = _validateLines();
    if (validationError != null) {
      emit(state.copyWith(status: AddCustomerDebtStatus.failure, errorMessage: validationError));
      return;
    }

    emit(state.copyWith(status: AddCustomerDebtStatus.saving));
    final items = state.lines
        .where((line) => line.name.trim().isNotEmpty)
        .map((line) => EntryItemModel(name: line.name.trim(), price: parseMoney(line.priceText)!))
        .toList();
    final result = await _customersRepo.addDebt(customer: customer, items: items, note: state.note);
    result.fold(
      (failure) => emit(state.copyWith(status: AddCustomerDebtStatus.failure, errorMessage: failure.message)),
      (saved) => emit(state.copyWith(status: AddCustomerDebtStatus.saved, savedResult: saved)),
    );
  }

  Future<String?> sendMessageNow() async {
    final saved = state.savedResult;
    if (saved == null) return null;
    final result = await _customersRepo.sendQueuedMessageNow(saved);
    return result.fold((failure) => failure.message, (_) => null);
  }

  String? _validateLines() {
    var hasAnyItem = false;
    for (final line in state.lines) {
      final name = line.name.trim();
      final hasPrice = line.priceText.trim().isNotEmpty;
      if (name.isEmpty && !hasPrice) continue;
      if (name.isEmpty) return 'اكتب اسم الصنف قبل السعر';
      if (parseMoney(line.priceText) == null) return 'اكتب سعر "$name"';
      hasAnyItem = true;
    }
    return hasAnyItem ? null : 'أضف صنفاً واحداً على الأقل مع سعره';
  }
}
