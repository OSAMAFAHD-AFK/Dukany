import 'dart:convert';

import '../../../../core/models/party_type.dart';
import '../../../../core/utils/functions/money_formatter.dart';
import '../../../../core/utils/local_database_service.dart';

typedef StatementRawEntry = ({DateTime date, String description, double debit, double credit});

/// Reads a customer's or supplier's operations for a period.
class StatementLocalDataSource {
  StatementLocalDataSource(this._database);

  final LocalDatabaseService _database;

  Future<({String name, String? phone})?> getParty(PartyType type, String partyId) async {
    final rows = await _database.db.query(
      type == PartyType.customer ? LocalTables.customers : LocalTables.suppliers,
      columns: ['name', 'phone'],
      where: 'id = ?',
      whereArgs: [partyId],
    );
    if (rows.isEmpty) return null;
    return (name: rows.first['name'] as String, phone: rows.first['phone'] as String?);
  }

  /// Balance of everything strictly before [from].
  Future<double> getOpeningBalance(PartyType type, String partyId, DateTime? from) async {
    if (from == null) return 0;
    final config = _config(type);
    final rows = await _database.db.rawQuery(
      '''SELECT COALESCE(SUM(CASE WHEN kind = ? THEN amount ELSE -amount END), 0) AS balance
         FROM ${config.table}
         WHERE ${config.foreignKey} = ? AND is_deleted = 0 AND created_at < ?''',
      [config.debitKind, partyId, from.toIso8601String()],
    );
    return (rows.first['balance'] as num).toDouble();
  }

  Future<List<StatementRawEntry>> getEntries(PartyType type, String partyId, {DateTime? from, DateTime? to}) async {
    final config = _config(type);
    final where = StringBuffer('${config.foreignKey} = ? AND is_deleted = 0');
    final args = <Object>[partyId];
    if (from != null) {
      where.write(' AND created_at >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where.write(' AND created_at < ?');
      args.add(to.toIso8601String());
    }
    final rows = await _database.db.query(
      config.table,
      where: where.toString(),
      whereArgs: args,
      orderBy: 'created_at ASC',
    );

    return rows.map((row) {
      final amount = (row['amount'] as num).toDouble();
      final isDebit = row['kind'] == config.debitKind;
      return (
        date: DateTime.parse(row['created_at'] as String),
        description: _describe(type, row, isDebit),
        debit: isDebit ? amount : 0.0,
        credit: isDebit ? 0.0 : amount,
      );
    }).toList();
  }

  String _describe(PartyType type, Map<String, Object?> row, bool isDebit) {
    final note = (row['note'] as String?)?.trim();
    String withNote(String text) => note == null || note.isEmpty ? text : '$text — $note';
    if (!isDebit) return withNote(type == PartyType.customer ? 'تسديد' : 'دفعة للمورد');
    if (type == PartyType.supplier) return withNote('فاتورة بضاعة');

    final items = jsonDecode(row['items'] as String? ?? '[]') as List;
    if (items.isEmpty) return withNote('مشتريات');
    return withNote(items.map((item) => '${(item as Map)['name']} (${formatMoney(item['price'] as num)})').join('، '));
  }

  ({String table, String foreignKey, String debitKind}) _config(PartyType type) => type == PartyType.customer
      ? (table: LocalTables.customerEntries, foreignKey: 'customer_id', debitKind: 'debt')
      : (table: LocalTables.supplierEntries, foreignKey: 'supplier_id', debitKind: 'invoice');
}
