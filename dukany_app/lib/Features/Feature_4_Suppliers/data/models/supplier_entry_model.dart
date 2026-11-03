import 'package:equatable/equatable.dart';

enum SupplierEntryKind {
  /// A wholesale invoice (adds to what the shop owes).
  invoice,

  /// Money the shop paid the supplier (reduces what it owes).
  payment;

  static SupplierEntryKind fromName(String name) =>
      name == 'payment' ? SupplierEntryKind.payment : SupplierEntryKind.invoice;
}

class SupplierEntryModel extends Equatable {
  const SupplierEntryModel({
    required this.id,
    required this.supplierId,
    required this.kind,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.localImagePath,
    this.remoteImagePath,
    this.isSynced = false,
  });

  final String id;
  final String supplierId;
  final SupplierEntryKind kind;
  final double amount;
  final String? note;

  /// Photo kept on the device (app documents folder).
  final String? localImagePath;

  /// Path inside the private "invoices" bucket once uploaded.
  final String? remoteImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  bool get isInvoice => kind == SupplierEntryKind.invoice;

  bool get hasImage => localImagePath != null || remoteImagePath != null;

  String get description {
    final base = isInvoice ? 'فاتورة بضاعة' : 'دفعة للمورد';
    return note?.isNotEmpty == true ? '$base — $note' : base;
  }

  factory SupplierEntryModel.fromDb(Map<String, Object?> row) => SupplierEntryModel(
    id: row['id'] as String,
    supplierId: row['supplier_id'] as String,
    kind: SupplierEntryKind.fromName(row['kind'] as String),
    amount: (row['amount'] as num).toDouble(),
    note: row['note'] as String?,
    localImagePath: row['local_image_path'] as String?,
    remoteImagePath: row['remote_image_path'] as String?,
    createdAt: DateTime.parse(row['created_at'] as String),
    updatedAt: DateTime.parse(row['updated_at'] as String),
    isSynced: (row['is_synced'] as int? ?? 0) == 1,
  );

  Map<String, Object?> toDb() => {
    'id': id,
    'supplier_id': supplierId,
    'kind': kind.name,
    'amount': amount,
    'note': note,
    'local_image_path': localImagePath,
    'remote_image_path': remoteImagePath,
    'is_deleted': 0,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_synced': isSynced ? 1 : 0,
  };

  @override
  List<Object?> get props => [
    id,
    supplierId,
    kind,
    amount,
    note,
    localImagePath,
    remoteImagePath,
    createdAt,
    updatedAt,
    isSynced,
  ];
}
