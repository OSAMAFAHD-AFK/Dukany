import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around the Supabase client so data sources never touch
/// the global singleton directly (easy to mock in tests).
class ApiService {
  ApiService(this._client);

  final SupabaseClient _client;

  GoTrueClient get auth => _client.auth;

  SupabaseStorageClient get storage => _client.storage;

  String? get currentUserId => _client.auth.currentUser?.id;

  SupabaseQueryBuilder table(String name) => _client.from(name);
}
