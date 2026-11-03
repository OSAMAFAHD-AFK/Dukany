import 'package:equatable/equatable.dart';

import '../../../../core/models/party_type.dart';
import 'statement_period.dart';

class StatementLineModel extends Equatable {
  const StatementLineModel({
    required this.date,
    required this.description,
    required this.debit,
    required this.credit,
    required this.runningBalance,
  });

  final DateTime date;
  final String description;

  /// Increases the balance (customer debt / supplier invoice).
  final double debit;

  /// Decreases the balance (payment).
  final double credit;
  final double runningBalance;

  @override
  List<Object?> get props => [date, description, debit, credit, runningBalance];
}

class StatementModel extends Equatable {
  const StatementModel({
    required this.partyType,
    required this.partyName,
    required this.partyPhone,
    required this.shopName,
    required this.period,
    required this.from,
    required this.to,
    required this.openingBalance,
    required this.lines,
  });

  final PartyType partyType;
  final String partyName;
  final String? partyPhone;
  final String shopName;
  final StatementPeriod period;
  final DateTime? from;
  final DateTime? to;
  final double openingBalance;

  /// Oldest first, as in a paper statement.
  final List<StatementLineModel> lines;

  double get totalDebit => lines.fold<double>(0, (sum, line) => sum + line.debit);

  double get totalCredit => lines.fold<double>(0, (sum, line) => sum + line.credit);

  double get closingBalance => openingBalance + totalDebit - totalCredit;

  bool get isCustomer => partyType == PartyType.customer;

  String get debitLabel => isCustomer ? 'مشتريات (دين)' : 'فواتير';

  String get creditLabel => isCustomer ? 'تسديدات' : 'دفعات';

  String get balanceLabel => isCustomer ? 'المتبقي على الزبون' : 'المتبقي للمورد';

  @override
  List<Object?> get props => [partyType, partyName, partyPhone, shopName, period, from, to, openingBalance, lines];
}
