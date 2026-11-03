import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'app_config.dart';

/// Table names shared by every feature's local data source.
abstract class LocalTables {
  static const String customers = 'customers';
  static const String customerEntries = 'customer_entries';
  static const String suppliers = 'suppliers';
  static const String supplierEntries = 'supplier_entries';
  static const String pendingMessages = 'pending_messages';

  /// Order matters when uploading (parents before children).
  static const List<String> syncedTables = [customers, suppliers, customerEntries, supplierEntries];
}

/// The device database is the source of truth: the app works fully offline
/// and every row carries `is_synced` until the sync button uploads it.
class LocalDatabaseService {
  static const int _version = 1;

  Database? _database;
  final StreamController<void> _changesController = StreamController<void>.broadcast();

  Database get db {
    final database = _database;
    if (database == null) throw StateError('LocalDatabaseService.init() was not called');
    return database;
  }

  /// Fires after any write so screens and the sync badge refresh themselves.
  Stream<void> get changes => _changesController.stream;

  void notifyChanged() => _changesController.add(null);

  Future<void> init() async {
    final path = join(await getDatabasesPath(), AppConfig.localDatabaseName);
    _database = await openDatabase(
      path,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createSchema,
    );
  }

  Future<void> _createSchema(Database db, int version) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE ${LocalTables.customers} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )''');
    batch.execute('''
      CREATE TABLE ${LocalTables.customerEntries} (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL REFERENCES ${LocalTables.customers}(id) ON DELETE CASCADE,
        kind TEXT NOT NULL,
        items TEXT NOT NULL DEFAULT '[]',
        amount REAL NOT NULL,
        note TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )''');
    batch.execute('''
      CREATE TABLE ${LocalTables.suppliers} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )''');
    batch.execute('''
      CREATE TABLE ${LocalTables.supplierEntries} (
        id TEXT PRIMARY KEY,
        supplier_id TEXT NOT NULL REFERENCES ${LocalTables.suppliers}(id) ON DELETE CASCADE,
        kind TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        local_image_path TEXT,
        remote_image_path TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )''');
    batch.execute('''
      CREATE TABLE ${LocalTables.pendingMessages} (
        id TEXT PRIMARY KEY,
        entry_id TEXT,
        recipient_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        body TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_sent INTEGER NOT NULL DEFAULT 0
      )''');
    batch.execute(
      'CREATE INDEX idx_customer_entries_customer ON ${LocalTables.customerEntries}(customer_id, is_deleted)',
    );
    batch.execute(
      'CREATE INDEX idx_supplier_entries_supplier ON ${LocalTables.supplierEntries}(supplier_id, is_deleted)',
    );
    await batch.commit(noResult: true);
  }

  /// Used on logout so another shop never sees this shop's data.
  Future<void> clearAllData() async {
    await db.transaction((txn) async {
      await txn.delete(LocalTables.pendingMessages);
      await txn.delete(LocalTables.customerEntries);
      await txn.delete(LocalTables.supplierEntries);
      await txn.delete(LocalTables.customers);
      await txn.delete(LocalTables.suppliers);
    });
    notifyChanged();
  }
}
