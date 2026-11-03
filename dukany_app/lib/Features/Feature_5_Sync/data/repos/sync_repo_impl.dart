import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/functions/whatsapp_launcher.dart';
import '../../../../core/utils/local_database_service.dart';
import '../../../../core/utils/shop_session_storage.dart';
import '../data_sources/sync_local_data_source.dart';
import '../data_sources/sync_remote_data_source.dart';
import '../models/pending_counts_model.dart';
import '../models/pending_message_model.dart';
import '../models/sync_report_model.dart';
import 'sync_repo.dart';

class SyncRepoImpl implements SyncRepo {
  SyncRepoImpl(this._localDataSource, this._remoteDataSource, this._shopSessionStorage);

  final SyncLocalDataSource _localDataSource;
  final SyncRemoteDataSource _remoteDataSource;
  final ShopSessionStorage _shopSessionStorage;

  @override
  Stream<void> get changes => _localDataSource.changes;

  @override
  Future<Either<Failure, PendingCountsModel>> getPendingCounts() async {
    try {
      return Right(await _localDataSource.getPendingCounts());
    } catch (_) {
      return const Left(LocalDatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, SyncReportModel>> uploadPendingData() async {
    try {
      final shopResult = await _refreshShop();
      if (shopResult.isLeft()) return shopResult.map((_) => const SyncReportModel(uploadedRows: 0, uploadedImages: 0));
      final shopId = shopResult.getOrElse(() => '');

      final uploadedImages = await _uploadInvoiceImages(shopId);

      var uploadedRows = 0;
      for (final table in LocalTables.syncedTables) {
        final rows = await _localDataSource.getUnsyncedRows(table);
        if (rows.isEmpty) continue;
        await _remoteDataSource.upsertRows(table, rows.map((row) => _toRemote(table, row, shopId)).toList());
        await _localDataSource.markRowsSynced(table, rows);
        uploadedRows += rows.length;
      }
      _localDataSource.notifyChanged();
      return Right(SyncReportModel(uploadedRows: uploadedRows, uploadedImages: uploadedImages));
    } catch (error) {
      _localDataSource.notifyChanged();
      return Left(ServerFailure.fromException(error));
    }
  }

  /// Confirms with Supabase that the shop is still active (the server
  /// enforces it again through RLS) and refreshes the cached session.
  Future<Either<Failure, String>> _refreshShop() async {
    final shop = await _remoteDataSource.fetchOwnShop();
    if (shop == null) return const Left(SubscriptionInactiveFailure('انتهت الجلسة، سجّل الدخول مرة أخرى'));
    await _shopSessionStorage.save(shop);
    if (!shop.canUseApp) return const Left(SubscriptionInactiveFailure());
    return Right(shop.shopId);
  }

  Future<int> _uploadInvoiceImages(String shopId) async {
    var uploaded = 0;
    for (final row in await _localDataSource.getEntriesWithImagesToUpload()) {
      final localPath = row['local_image_path'] as String;
      if (!File(localPath).existsSync()) continue;
      final entryId = row['id'] as String;
      final remotePath = await _remoteDataSource.uploadInvoiceImage(
        shopId: shopId,
        entryId: entryId,
        localPath: localPath,
      );
      await _localDataSource.setRemoteImagePath(entryId, remotePath);
      uploaded++;
    }
    return uploaded;
  }

  /// Local SQLite row → Supabase row (UTC timestamps, real booleans, shop id).
  Map<String, dynamic> _toRemote(String table, Map<String, Object?> row, String shopId) {
    final common = <String, dynamic>{
      'id': row['id'],
      'shop_id': shopId,
      'is_deleted': row['is_deleted'] == 1,
      'created_at': _utc(row['created_at']),
      'updated_at': _utc(row['updated_at']),
    };
    switch (table) {
      case LocalTables.customers:
      case LocalTables.suppliers:
        return {...common, 'name': row['name'], 'phone': row['phone']};
      case LocalTables.customerEntries:
        return {
          ...common,
          'customer_id': row['customer_id'],
          'kind': row['kind'],
          'items': jsonDecode(row['items'] as String? ?? '[]'),
          'amount': row['amount'],
          'note': row['note'],
        };
      case LocalTables.supplierEntries:
        return {
          ...common,
          'supplier_id': row['supplier_id'],
          'kind': row['kind'],
          'amount': row['amount'],
          'note': row['note'],
          'image_path': row['remote_image_path'],
        };
      default:
        throw ArgumentError('Unknown table $table');
    }
  }

  /// Supabase row → local SQLite row (local timestamps, flagged as synced).
  Map<String, Object?> _toLocal(String table, Map<String, dynamic> row) {
    final common = <String, Object?>{
      'id': row['id'],
      'is_deleted': row['is_deleted'] == true ? 1 : 0,
      'created_at': _local(row['created_at']),
      'updated_at': _local(row['updated_at']),
      'is_synced': 1,
    };
    switch (table) {
      case LocalTables.customers:
      case LocalTables.suppliers:
        return {...common, 'name': row['name'], 'phone': row['phone']};
      case LocalTables.customerEntries:
        return {
          ...common,
          'customer_id': row['customer_id'],
          'kind': row['kind'],
          'items': jsonEncode(row['items'] ?? const []),
          'amount': (row['amount'] as num).toDouble(),
          'note': row['note'],
        };
      case LocalTables.supplierEntries:
        return {
          ...common,
          'supplier_id': row['supplier_id'],
          'kind': row['kind'],
          'amount': (row['amount'] as num).toDouble(),
          'note': row['note'],
          'remote_image_path': row['image_path'],
        };
      default:
        throw ArgumentError('Unknown table $table');
    }
  }

  String _utc(Object? localIso) => DateTime.parse(localIso as String).toUtc().toIso8601String();

  String _local(Object? remoteIso) => DateTime.parse(remoteIso as String).toLocal().toIso8601String();

  @override
  Future<Either<Failure, List<PendingMessageModel>>> getUnsentMessages() async {
    try {
      return Right(await _localDataSource.getUnsentMessages());
    } catch (_) {
      return const Left(LocalDatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendMessage(PendingMessageModel message) async {
    final opened = await openWhatsAppChat(phone: message.phone, message: message.body);
    if (!opened) return const Left(ValidationFailure('تعذّر فتح واتساب، تأكد أنه مثبت على الجوال'));
    return dismissMessage(message);
  }

  @override
  Future<Either<Failure, Unit>> dismissMessage(PendingMessageModel message) async {
    try {
      await _localDataSource.markMessageSent(message.id);
      return const Right(unit);
    } catch (_) {
      return const Left(LocalDatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> restoreFromCloudIfNeeded() async {
    try {
      if (await _localDataSource.hasAnyLocalData()) return const Right(false);

      final rowsByTable = <String, List<Map<String, Object?>>>{};
      for (final table in LocalTables.syncedTables) {
        final remoteRows = await _remoteDataSource.fetchAllRows(table);
        rowsByTable[table] = remoteRows.map((row) => _toLocal(table, row)).toList();
      }
      await _localDataSource.insertRestoredRows(rowsByTable);
      return Right(rowsByTable.values.any((rows) => rows.isNotEmpty));
    } catch (error) {
      return Left(ServerFailure.fromException(error));
    }
  }
}
