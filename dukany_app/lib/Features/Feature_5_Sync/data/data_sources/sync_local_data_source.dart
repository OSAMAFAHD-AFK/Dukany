import 'package:sqflite/sqflite.dart';

import '../../../../core/utils/local_database_service.dart';
import '../models/pending_counts_model.dart';
import '../models/pending_message_model.dart';

class SyncLocalDataSource {
  SyncLocalDataSource(this._database);

  final LocalDatabaseService _database;

  Stream<void> get changes => _database.changes;

  void notifyChanged() => _database.notifyChanged();

  Future<PendingCountsModel> getPendingCounts() async {
    var operations = 0;
    for (final table in LocalTables.syncedTables) {
      operations +=
          Sqflite.firstIntValue(await _database.db.rawQuery('SELECT COUNT(*) FROM $table WHERE is_synced = 0')) ?? 0;
    }
    final messages =
        Sqflite.firstIntValue(
          await _database.db.rawQuery('SELECT COUNT(*) FROM ${LocalTables.pendingMessages} WHERE is_sent = 0'),
        ) ??
        0;
    return PendingCountsModel(operations: operations, messages: messages);
  }

  Future<List<Map<String, Object?>>> getUnsyncedRows(String table) =>
      _database.db.query(table, where: 'is_synced = 0', orderBy: 'created_at ASC');

  /// Supplier invoices whose photo is still only on the phone.
  Future<List<Map<String, Object?>>> getEntriesWithImagesToUpload() => _database.db.query(
    LocalTables.supplierEntries,
    where: 'local_image_path IS NOT NULL AND remote_image_path IS NULL AND is_deleted = 0',
  );

  /// Also flags the row for upload so Supabase gets the image path even if
  /// the row itself was uploaded earlier (e.g. the photo failed last time).
  Future<void> setRemoteImagePath(String entryId, String remotePath) => _database.db.update(
    LocalTables.supplierEntries,
    {'remote_image_path': remotePath, 'is_synced': 0},
    where: 'id = ?',
    whereArgs: [entryId],
  );

  /// Marks rows as uploaded — but only if they were not edited meanwhile
  /// (same updated_at), so a change made during the upload is not lost.
  Future<void> markRowsSynced(String table, List<Map<String, Object?>> rows) async {
    final batch = _database.db.batch();
    for (final row in rows) {
      batch.update(
        table,
        {'is_synced': 1},
        where: 'id = ? AND updated_at = ?',
        whereArgs: [row['id'], row['updated_at']],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<PendingMessageModel>> getUnsentMessages() async {
    final rows = await _database.db.query(LocalTables.pendingMessages, where: 'is_sent = 0', orderBy: 'created_at ASC');
    return rows.map(PendingMessageModel.fromDb).toList();
  }

  Future<void> markMessageSent(String messageId) async {
    await _database.db.update(LocalTables.pendingMessages, {'is_sent': 1}, where: 'id = ?', whereArgs: [messageId]);
    _database.notifyChanged();
  }

  Future<bool> hasAnyLocalData() async {
    final customers = Sqflite.firstIntValue(
      await _database.db.rawQuery('SELECT COUNT(*) FROM ${LocalTables.customers}'),
    );
    final suppliers = Sqflite.firstIntValue(
      await _database.db.rawQuery('SELECT COUNT(*) FROM ${LocalTables.suppliers}'),
    );
    return (customers ?? 0) + (suppliers ?? 0) > 0;
  }

  /// Writes rows downloaded from Supabase (already marked as synced).
  Future<void> insertRestoredRows(Map<String, List<Map<String, Object?>>> rowsByTable) async {
    await _database.db.transaction((txn) async {
      for (final table in LocalTables.syncedTables) {
        final batch = txn.batch();
        for (final row in rowsByTable[table] ?? const <Map<String, Object?>>[]) {
          batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      }
    });
    _database.notifyChanged();
  }
}
