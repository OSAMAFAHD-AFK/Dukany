import 'package:sqflite/sqflite.dart';

import '../../../../core/utils/local_database_service.dart';
import '../models/dashboard_summary_model.dart';
import '../models/recent_activity_model.dart';

class HomeLocalDataSource {
  HomeLocalDataSource(this._database);

  final LocalDatabaseService _database;

  Stream<void> get changes => _database.changes;

  Future<DashboardSummaryModel> getDashboardSummary() async {
    final db = _database.db;
    final customers = await _balances(
      db,
      parentTable: LocalTables.customers,
      entriesTable: LocalTables.customerEntries,
      foreignKey: 'customer_id',
      debitKind: 'debt',
    );
    final suppliers = await _balances(
      db,
      parentTable: LocalTables.suppliers,
      entriesTable: LocalTables.supplierEntries,
      foreignKey: 'supplier_id',
      debitKind: 'invoice',
    );

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
    final todayRows = await db.rawQuery(
      '''SELECT
           COALESCE(SUM(CASE WHEN kind = 'debt' THEN amount END), 0) AS debts,
           COALESCE(SUM(CASE WHEN kind = 'payment' THEN amount END), 0) AS collected
         FROM ${LocalTables.customerEntries}
         WHERE is_deleted = 0 AND created_at >= ?''',
      [todayStart],
    );

    // The UNION is wrapped in a sub-query: SQLite only lets a compound
    // SELECT be ordered by a plain result-column name.
    final recentRows = await db.rawQuery('''
      SELECT * FROM (
        SELECT 'customer' AS party_type, c.id AS party_id, c.name AS party_name,
               e.kind AS kind, e.amount AS amount, e.created_at AS created_at, e.is_synced AS is_synced
        FROM ${LocalTables.customerEntries} e JOIN ${LocalTables.customers} c ON c.id = e.customer_id
        WHERE e.is_deleted = 0
        UNION ALL
        SELECT 'supplier', s.id, s.name, e.kind, e.amount, e.created_at, e.is_synced
        FROM ${LocalTables.supplierEntries} e JOIN ${LocalTables.suppliers} s ON s.id = e.supplier_id
        WHERE e.is_deleted = 0
      )
      ORDER BY created_at DESC
      LIMIT 8''');

    return DashboardSummaryModel(
      customersOwe: customers.owed,
      customersCount: customers.count,
      suppliersDue: suppliers.owed,
      suppliersCount: suppliers.count,
      todayDebts: (todayRows.first['debts'] as num).toDouble(),
      todayCollected: (todayRows.first['collected'] as num).toDouble(),
      recentActivity: recentRows.map(RecentActivityModel.fromDb).toList(),
    );
  }

  /// Sum of positive balances (what is actually owed) + number of accounts.
  Future<({double owed, int count})> _balances(
    Database db, {
    required String parentTable,
    required String entriesTable,
    required String foreignKey,
    required String debitKind,
  }) async {
    final rows = await db.rawQuery(
      '''
      SELECT COUNT(*) AS accounts, COALESCE(SUM(CASE WHEN balance > 0 THEN balance ELSE 0 END), 0) AS owed
      FROM (
        SELECT p.id, COALESCE(SUM(CASE WHEN e.kind = ? THEN e.amount ELSE -e.amount END), 0) AS balance
        FROM $parentTable p
        LEFT JOIN $entriesTable e ON e.$foreignKey = p.id AND e.is_deleted = 0
        WHERE p.is_deleted = 0
        GROUP BY p.id
      )''',
      [debitKind],
    );
    return (owed: (rows.first['owed'] as num).toDouble(), count: rows.first['accounts'] as int);
  }
}
