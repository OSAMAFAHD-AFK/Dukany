import 'package:sqflite/sqflite.dart';

import '../../../../core/utils/local_database_service.dart';
import '../models/supplier_entry_model.dart';
import '../models/supplier_model.dart';

class SuppliersLocalDataSource {
  SuppliersLocalDataSource(this._database);

  final LocalDatabaseService _database;

  Stream<void> get changes => _database.changes;

  static const String _suppliersWithBalanceSql =
      '''
    SELECT s.*,
           COALESCE(SUM(CASE WHEN e.kind = 'invoice' THEN e.amount ELSE -e.amount END), 0) AS balance,
           MAX(e.created_at) AS last_entry_at
    FROM ${LocalTables.suppliers} s
    LEFT JOIN ${LocalTables.supplierEntries} e
           ON e.supplier_id = s.id AND e.is_deleted = 0
    WHERE s.is_deleted = 0
  ''';

  Future<List<SupplierModel>> getSuppliers({String query = ''}) async {
    final trimmed = query.trim();
    final rows = await _database.db.rawQuery(
      '$_suppliersWithBalanceSql'
      '${trimmed.isEmpty ? '' : ' AND s.name LIKE ?'}'
      ' GROUP BY s.id ORDER BY COALESCE(MAX(e.created_at), s.created_at) DESC',
      trimmed.isEmpty ? null : ['%$trimmed%'],
    );
    return rows.map(SupplierModel.fromDb).toList();
  }

  Future<SupplierModel?> getSupplierById(String id) async {
    final rows = await _database.db.rawQuery('$_suppliersWithBalanceSql AND s.id = ? GROUP BY s.id', [id]);
    return rows.isEmpty ? null : SupplierModel.fromDb(rows.first);
  }

  Future<void> insertSupplier(SupplierModel supplier) async {
    await _database.db.insert(LocalTables.suppliers, supplier.toDb());
    _database.notifyChanged();
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    await _database.db.update(
      LocalTables.suppliers,
      {
        'name': supplier.name,
        'phone': supplier.phone,
        'updated_at': supplier.updatedAt.toIso8601String(),
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
    _database.notifyChanged();
  }

  Future<List<SupplierEntryModel>> getEntries(String supplierId) async {
    final rows = await _database.db.query(
      LocalTables.supplierEntries,
      where: 'supplier_id = ? AND is_deleted = 0',
      whereArgs: [supplierId],
      orderBy: 'created_at DESC',
    );
    return rows.map(SupplierEntryModel.fromDb).toList();
  }

  /// Inserts the entry and returns what is still owed to the supplier.
  Future<double> insertEntry(SupplierEntryModel entry) async {
    final balance = await _database.db.transaction((txn) async {
      await txn.insert(LocalTables.supplierEntries, entry.toDb());
      return _balance(txn, entry.supplierId);
    });
    _database.notifyChanged();
    return balance;
  }

  Future<void> softDeleteEntry(String entryId) async {
    await _database.db.update(
      LocalTables.supplierEntries,
      {'is_deleted': 1, 'is_synced': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [entryId],
    );
    _database.notifyChanged();
  }

  Future<double> _balance(DatabaseExecutor executor, String supplierId) async {
    final rows = await executor.rawQuery(
      '''SELECT COALESCE(SUM(CASE WHEN kind = 'invoice' THEN amount ELSE -amount END), 0) AS balance
         FROM ${LocalTables.supplierEntries} WHERE supplier_id = ? AND is_deleted = 0''',
      [supplierId],
    );
    return (rows.first['balance'] as num).toDouble();
  }
}
