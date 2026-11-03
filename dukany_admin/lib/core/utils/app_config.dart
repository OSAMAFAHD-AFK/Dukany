/// Same Supabase project as the Dukany app.
/// Supabase Dashboard → Project Settings → API.
abstract class AppConfig {
  static const String supabaseUrl = 'https://uyghqswsqxcyfxtnkxih.supabase.co';
  static const String supabasePublishableKey = 'sb_publishable_UFktT49YMJ_bOHvf39sQnw_2RT-UzRY';

  /// Edge Function that holds the service-role key (create shop / reset password).
  static const String manageShopsFunction = 'admin-manage-shops';
}
