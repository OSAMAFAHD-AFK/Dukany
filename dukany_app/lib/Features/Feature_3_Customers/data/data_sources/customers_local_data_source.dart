import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/utils/local_database_service.dart';
import '../models/customer_entry_model.dart';
import '../models/customer_model.dart';

class CustomersLocalDataSource {
  CustomersLocalDataSource(this._database);

  final LocalDatabaseService _database;

  Stream<void> get changes => _database.changes;

  static const String _customersWithBalanceSql =
      '''
    SELECT c.*,
           COALESCE(SUM(CASE WHEN e.kind = 'debt' THEN e.amount ELSE -e.amount END), 0) AS balance,
           MAX(e.created_at) AS last_entry_at
    FROM ${LocalTables.customers} c
    LEFT JOIN ${LocalTables.customerEntries} e
           ON e.customer_id = c.id AND e.is_deleted = 0
    WHERE c.is_deleted = 0
  ''';

  /// Most recently active customers first.
  Future<List<CustomerModel>> getCustomers({String query = ''}) async {
    final trimmed = query.trim();
    final rows = await _database.db.rawQuery(
      '$_customersWithBalanceSql'
      '${trimmed.isEmpty ? '' : ' AND (c.name LIKE ? OR c.phone LIKE ?)'}'
      ' GROUP BY c.id ORDER BY COALESCE(MAX(e.created_at), c.created_at) DESC',
      trimmed.isEmpty ? null : ['%$trimmed%', '%$trimmed%'],
    );
    return rows.map(CustomerModel.fromDb).toList();
  }

  Future<CustomerModel?> getCustomerById(String id) async {
    final rows = await _database.db.rawQuery('$_customersWithBalanceSql AND c.id = ? GROUP BY c.id', [id]);
    return rows.isEmpty ? null : CustomerModel.fromDb(rows.first);
  }

  Future<double> getBalance(DatabaseExecutor executor, String customerId) async {
    final rows = await executor.rawQuery(
      '''SELECT COALESCE(SUM(CASE WHEN kind = 'debt' THEN amount ELSE -amount END), 0) AS balance
         FROM ${LocalTables.customerEntries} WHERE customer_id = ? AND is_deleted = 0''',
      [customerId],
    );
    return (rows.first['balance'] as num).toDouble();
  }

  Future<void> insertCustomer(CustomerModel customer) async {
    await _database.db.insert(LocalTables.customers, customer.toDb());
    _database.notifyChanged();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _database.db.update(
      LocalTables.customers,
      {
        'name': customer.name,
        'phone': customer.phone,
        'updated_at': customer.updatedAt.toIso8601String(),
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [customer.id],
    );
    _database.notifyChanged();
  }

  Future<List<CustomerEntryModel>> getEntries(String customerId) async {
    final rows = await _database.db.query(
      LocalTables.customerEntries,
      where: 'customer_id = ? AND is_deleted = 0',
      whereArgs: [customerId],
      orderBy: 'created_at DESC',
    );
    return rows.map(CustomerEntryModel.fromDb).toList();
  }

  /// Saves the entry and (optionally) its WhatsApp message in one
  /// transaction, then returns the customer's new balance.
  /// [buildMessage] receives the new balance and returns the message row.
  Future<double> insertEntryWithMessage(
    CustomerEntryModel entry, {
    Map<String, Object?> Function(double newBalance)? buildMessage,
  }) async {
    final newBalance = await _database.db.transaction((txn) async {
      await txn.insert(LocalTables.customerEntries, entry.toDb());
      final balance = await getBalance(txn, entry.customerId);
      final message = buildMessage?.call(balance);
      if (message != null) await txn.insert(LocalTables.pendingMessages, message);
      return balance;
    });
    _database.notifyChanged();
    return newBalance;
  }

  /// Soft delete keeps history in Supabase; an unsent message for the
  /// entry is dropped so the customer never gets a wrong notice.
  Future<void> softDeleteEntry(String entryId) async {
    await _database.db.transaction((txn) async {
      await txn.update(
        LocalTables.customerEntries,
        {'is_deleted': 1, 'is_synced': 0, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [entryId],
      );
      await txn.delete(LocalTables.pendingMessages, where: 'entry_id = ? AND is_sent = 0', whereArgs: [entryId]);
    });
    _database.notifyChanged();
  }

  Future<void> markMessageSent(String messageId) async {
    await _database.db.update(LocalTables.pendingMessages, {'is_sent': 1}, where: 'id = ?', whereArgs: [messageId]);
    _database.notifyChanged();
  }

  /// Item names this shop types most often (shown as quick chips).
  Future<List<String>> getFrequentItemNames({int limit = 10}) async {
    final rows = await _database.db.query(
      LocalTables.customerEntries,
      columns: ['items'],
      where: "kind = 'debt' AND is_deleted = 0",
      orderBy: 'created_at DESC',
      limit: 300,
    );
    final counts = <String, int>{};
    for (final row in rows) {
      final items = jsonDecode(row['items'] as String? ?? '[]') as List;
      for (final item in items) {
        final name = ((item as Map)['name'] as String).trim();
        if (name.isNotEmpty) counts[name] = (counts[name] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((entry) => entry.key).toList();
  }
}
