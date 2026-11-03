import '../../../../core/models/shop_session_model.dart';
import '../../../../core/utils/api_service.dart';
import '../../../../core/utils/app_config.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiService);

  final ApiService _apiService;

  bool get hasAuthSession => _apiService.auth.currentSession != null;

  /// [phone] must already be normalized (9677xxxxxxxx).
  Future<void> signIn({required String phone, required String password}) async {
    await _apiService.auth.signInWithPassword(email: '$phone@${AppConfig.loginEmailDomain}', password: password);
  }

  /// The shop linked to the signed-in user (RLS returns only that row).
  Future<ShopSessionModel?> fetchOwnShop() async {
    final userId = _apiService.currentUserId;
    if (userId == null) return null;
    final row = await _apiService.table('shops').select().eq('owner_id', userId).maybeSingle();
    return row == null ? null : ShopSessionModel.fromShopRow(row);
  }

  Future<void> signOut() => _apiService.auth.signOut();
}
