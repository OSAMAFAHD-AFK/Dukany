import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around the Supabase client used by every data source.
class ApiService {
  ApiService(this._client);

  final SupabaseClient _client;

  GoTrueClient get auth => _client.auth;

  FunctionsClient get functions => _client.functions;

  SupabaseQueryBuilder table(String name) => _client.from(name);

  Future<T> rpc<T>(String functionName) async => await _client.rpc(functionName) as T;
}
