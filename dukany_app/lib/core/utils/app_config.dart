/// Project-wide constants. Fill the two Supabase values from
/// Supabase Dashboard → Project Settings → API.
abstract class AppConfig {
  static const String supabaseUrl = 'https://uyghqswsqxcyfxtnkxih.supabase.co';
  static const String supabasePublishableKey = 'sb_publishable_UFktT49YMJ_bOHvf39sQnw_2RT-UzRY';

  /// Shop owners log in with their phone number; Supabase Auth needs an
  /// email, so the phone is mapped to `<phone>@dukany.app`.
  /// Must match LOGIN_EMAIL_DOMAIN in the admin-manage-shops Edge Function.
  static const String loginEmailDomain = 'dukany.app';

  static const String invoicesBucket = 'invoices';
  static const String currencyLabel = 'ريال';
  static const String localDatabaseName = 'dukany.db';

  static bool get isSupabaseConfigured => !supabaseUrl.contains('YOUR-PROJECT-REF');
}
