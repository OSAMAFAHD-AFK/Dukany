import 'package:equatable/equatable.dart';

import '../../../../core/models/party_type.dart';

enum RecentActivityKind { customerDebt, customerPayment, supplierInvoice, supplierPayment }

class RecentActivityModel extends Equatable {
  const RecentActivityModel({
    required this.partyType,
    required this.partyId,
    required this.partyName,
    required this.kind,
    required this.amount,
    required this.createdAt,
    required this.isSynced,
  });

  final PartyType partyType;
  final String partyId;
  final String partyName;
  final RecentActivityKind kind;
  final double amount;
  final DateTime createdAt;
  final bool isSynced;

  String get label => switch (kind) {
    RecentActivityKind.customerDebt => 'دين جديد',
    RecentActivityKind.customerPayment => 'تسديد من زبون',
    RecentActivityKind.supplierInvoice => 'فاتورة مورد',
    RecentActivityKind.supplierPayment => 'دفعة لمورد',
  };

  factory RecentActivityModel.fromDb(Map<String, Object?> row) {
    final isCustomer = row['party_type'] == 'customer';
    final kind = row['kind'] as String;
    return RecentActivityModel(
      partyType: isCustomer ? PartyType.customer : PartyType.supplier,
      partyId: row['party_id'] as String,
      partyName: row['party_name'] as String,
      kind: switch (kind) {
        'debt' => RecentActivityKind.customerDebt,
        'invoice' => RecentActivityKind.supplierInvoice,
        _ => isCustomer ? RecentActivityKind.customerPayment : RecentActivityKind.supplierPayment,
      },
      amount: (row['amount'] as num).toDouble(),
      createdAt: DateTime.parse(row['created_at'] as String),
      isSynced: (row['is_synced'] as int? ?? 0) == 1,
    );
  }

  @override
  List<Object?> get props => [partyType, partyId, partyName, kind, amount, createdAt, isSynced];
}
