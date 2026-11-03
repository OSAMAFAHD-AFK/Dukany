import 'package:equatable/equatable.dart';

/// A wholesale company / distributor the shop buys from on credit.
class SupplierModel extends Equatable {
  const SupplierModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.balance = 0,
    this.lastEntryAt,
    this.isSynced = false,
  });

  final String id;
  final String name;
  final String? phone;

  /// Positive = the shop still owes this supplier.
  final double balance;
  final DateTime? lastEntryAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  bool get hasPhone => phone != null && phone!.isNotEmpty;

  factory SupplierModel.fromDb(Map<String, Object?> row) => SupplierModel(
    id: row['id'] as String,
    name: row['name'] as String,
    phone: row['phone'] as String?,
    balance: (row['balance'] as num?)?.toDouble() ?? 0,
    lastEntryAt: row['last_entry_at'] == null ? null : DateTime.parse(row['last_entry_at'] as String),
    createdAt: DateTime.parse(row['created_at'] as String),
    updatedAt: DateTime.parse(row['updated_at'] as String),
    isSynced: (row['is_synced'] as int? ?? 0) == 1,
  );

  Map<String, Object?> toDb() => {
    'id': id,
    'name': name,
    'phone': phone,
    'is_deleted': 0,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_synced': isSynced ? 1 : 0,
  };

  SupplierModel copyWith({String? name, String? phone, bool clearPhone = false, DateTime? updatedAt}) => SupplierModel(
    id: id,
    name: name ?? this.name,
    phone: clearPhone ? null : (phone ?? this.phone),
    balance: balance,
    lastEntryAt: lastEntryAt,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: false,
  );

  @override
  List<Object?> get props => [id, name, phone, balance, lastEntryAt, createdAt, updatedAt, isSynced];
}
