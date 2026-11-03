import '../../../../core/utils/api_service.dart';

class AdminAuthRemoteDataSource {
  AdminAuthRemoteDataSource(this._apiService);

  final ApiService _apiService;

  bool get hasSession => _apiService.auth.currentSession != null;

  String? get currentEmail => _apiService.auth.currentUser?.email;

  Future<void> signIn({required String email, required String password}) =>
      _apiService.auth.signInWithPassword(email: email.trim(), password: password);

  /// Server-side check (public.is_admin) — the UI never trusts itself.
  Future<bool> isCurrentUserAdmin() => _apiService.rpc<bool>('is_admin');

  Future<void> signOut() => _apiService.auth.signOut();
}
