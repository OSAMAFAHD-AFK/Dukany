import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/shop_session_model.dart';

/// Keeps the current shop (name, subscription end date…) on the device.
/// Shared by auth (login/logout), sync (shop id), customers (message text)
/// and statements (PDF header).
class ShopSessionStorage {
  ShopSessionStorage(this._preferences);

  static const String _key = 'shop_session';

  final SharedPreferences _preferences;

  ShopSessionModel? read() {
    final raw = _preferences.getString(_key);
    if (raw == null) return null;
    try {
      return ShopSessionModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ShopSessionModel session) => _preferences.setString(_key, jsonEncode(session.toJson()));

  Future<void> clear() => _preferences.remove(_key);

  String get shopName => read()?.shopName ?? 'البقالة';
}
