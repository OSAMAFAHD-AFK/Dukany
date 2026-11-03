import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/shop_session_model.dart';
import '../../../../core/utils/api_service.dart';
import '../../../../core/utils/app_config.dart';

class SyncRemoteDataSource {
  SyncRemoteDataSource(this._apiService);

  static const int _chunkSize = 200;
  static const int _pageSize = 1000;

  final ApiService _apiService;

  Future<ShopSessionModel?> fetchOwnShop() async {
    final userId = _apiService.currentUserId;
    if (userId == null) return null;
    final row = await _apiService.table('shops').select().eq('owner_id', userId).maybeSingle();
    return row == null ? null : ShopSessionModel.fromShopRow(row);
  }

  /// Uploads to the private bucket as `<shopId>/<entryId>.jpg`
  /// (RLS only allows a shop to write inside its own folder).
  Future<String> uploadInvoiceImage({
    required String shopId,
    required String entryId,
    required String localPath,
  }) async {
    final remotePath = '$shopId/$entryId.jpg';
    await _apiService.storage
        .from(AppConfig.invoicesBucket)
        .upload(remotePath, File(localPath), fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));
    return remotePath;
  }

  Future<void> upsertRows(String table, List<Map<String, dynamic>> rows) async {
    for (var start = 0; start < rows.length; start += _chunkSize) {
      final end = start + _chunkSize > rows.length ? rows.length : start + _chunkSize;
      await _apiService.table(table).upsert(rows.sublist(start, end), onConflict: 'id');
    }
  }

  /// Every row of [table] that RLS lets this shop read, page by page.
  Future<List<Map<String, dynamic>>> fetchAllRows(String table) async {
    final all = <Map<String, dynamic>>[];
    var from = 0;
    while (true) {
      final page = await _apiService.table(table).select().order('created_at').range(from, from + _pageSize - 1);
      all.addAll(page);
      if (page.length < _pageSize) break;
      from += _pageSize;
    }
    return all;
  }
}
