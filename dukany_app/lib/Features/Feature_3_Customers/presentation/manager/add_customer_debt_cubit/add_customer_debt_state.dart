part of 'add_customer_debt_cubit.dart';

enum AddCustomerDebtStatus { loading, ready, saving, saved, failure }

/// One row of the form exactly as typed (validated on save).
typedef DebtLineInput = ({String name, String priceText});

class AddCustomerDebtState extends Equatable {
  const AddCustomerDebtState({
    this.status = AddCustomerDebtStatus.loading,
    this.customer,
    this.frequentItemNames = const [],
    this.lines = const [],
    this.note = '',
    this.savedResult,
    this.errorMessage,
  });

  final AddCustomerDebtStatus status;
  final CustomerModel? customer;
  final List<String> frequentItemNames;
  final List<DebtLineInput> lines;
  final String note;
  final SavedEntryResultModel? savedResult;
  final String? errorMessage;

  double get total => lines.fold<double>(0, (sum, line) => sum + (parseMoney(line.priceText) ?? 0));

  int get filledLinesCount => lines.where((line) => parseMoney(line.priceText) != null).length;

  AddCustomerDebtState copyWith({
    AddCustomerDebtStatus? status,
    CustomerModel? customer,
    List<String>? frequentItemNames,
    List<DebtLineInput>? lines,
    String? note,
    SavedEntryResultModel? savedResult,
    String? errorMessage,
  }) => AddCustomerDebtState(
    status: status ?? this.status,
    customer: customer ?? this.customer,
    frequentItemNames: frequentItemNames ?? this.frequentItemNames,
    lines: lines ?? this.lines,
    note: note ?? this.note,
    savedResult: savedResult ?? this.savedResult,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, customer, frequentItemNames, lines, note, savedResult, errorMessage];
}
