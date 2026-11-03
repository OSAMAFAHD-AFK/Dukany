import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'entry_item_model.dart';

enum CustomerEntryKind {
  /// Goods taken on credit (adds to the balance).
  debt,

  /// Money the customer paid back (reduces the balance).
  payment;

  static CustomerEntryKind fromName(String name) =>
      name == 'payment' ? CustomerEntryKind.payment : CustomerEntryKind.debt;
}

class CustomerEntryModel extends Equatable {
  const CustomerEntryModel({
    required this.id,
    required this.customerId,
    required this.kind,
    required this.items,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.isSynced = false,
  });

  final String id;
  final String customerId;
  final CustomerEntryKind kind;
  final List<EntryItemModel> items;
  final double amount;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  bool get isDebt => kind == CustomerEntryKind.debt;

  /// "فاصوليا، جبن، خبز" or "تسديد نقدي".
  String get description {
    if (!isDebt) return note?.isNotEmpty == true ? 'تسديد — $note' : 'تسديد نقدي';
    if (items.isEmpty) return note?.isNotEmpty == true ? note! : 'مشتريات';
    return items.map((item) => item.name).join('، ');
  }

  factory CustomerEntryModel.fromDb(Map<String, Object?> row) => CustomerEntryModel(
    id: row['id'] as String,
    customerId: row['customer_id'] as String,
    kind: CustomerEntryKind.fromName(row['kind'] as String),
    items: (jsonDecode(row['items'] as String? ?? '[]') as List)
        .map((item) => EntryItemModel.fromJson(item as Map<String, dynamic>))
        .toList(),
    amount: (row['amount'] as num).toDouble(),
    note: row['note'] as String?,
    createdAt: DateTime.parse(row['created_at'] as String),
    updatedAt: DateTime.parse(row['updated_at'] as String),
    isSynced: (row['is_synced'] as int? ?? 0) == 1,
  );

  Map<String, Object?> toDb() => {
    'id': id,
    'customer_id': customerId,
    'kind': kind.name,
    'items': jsonEncode(items.map((item) => item.toJson()).toList()),
    'amount': amount,
    'note': note,
    'is_deleted': 0,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_synced': isSynced ? 1 : 0,
  };

  @override
  List<Object?> get props => [id, customerId, kind, items, amount, note, createdAt, updatedAt, isSynced];
}
