import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/api_service.dart';
import '../../../../core/utils/app_config.dart';
import '../models/new_shop_input_model.dart';
import '../models/shop_model.dart';

/// Reads/updates go straight to the table (RLS: admins only).
/// Creating a login and resetting a password need the service role, so
/// they go through the admin-manage-shops Edge Function.
class ShopsRemoteDataSource {
  ShopsRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<List<ShopModel>> fetchShops() async {
    final rows = await _apiService.table('shops').select().order('created_at', ascending: false);
    return rows.map(ShopModel.fromJson).toList();
  }

  Future<ShopModel> setActive(String shopId, bool isActive) async {
    final row = await _apiService.table('shops').update({'is_active': isActive}).eq('id', shopId).select().single();
    return ShopModel.fromJson(row);
  }

  Future<ShopModel> setSubscriptionEnd(String shopId, DateTime endsAt) async {
    final row = await _apiService
        .table('shops')
        .update({'subscription_ends_at': endsAt.toUtc().toIso8601String()})
        .eq('id', shopId)
        .select()
        .single();
    return ShopModel.fromJson(row);
  }

  Future<ShopModel> createShop(NewShopInputModel input) async {
    final response = await _apiService.functions.invoke(
      AppConfig.manageShopsFunction,
      headers: _userAuthHeaders(),
      body: input.toFunctionBody(),
    );
    final data = response.data as Map<String, dynamic>;
    return ShopModel.fromJson(data['shop'] as Map<String, dynamic>);
  }

  Future<void> resetPassword(String shopId, String newPassword) async {
    await _apiService.functions.invoke(
      AppConfig.manageShopsFunction,
      headers: _userAuthHeaders(),
      body: {'action': 'reset_password', 'shop_id': shopId, 'password': newPassword},
    );
  }

  /// The function identifies the admin from this token (not from the
  /// publishable key), so it is always sent explicitly.
  Map<String, String> _userAuthHeaders() {
    final token = _apiService.auth.currentSession?.accessToken;
    if (token == null) throw const AuthException('no session');
    return {'Authorization': 'Bearer $token'};
  }
}
