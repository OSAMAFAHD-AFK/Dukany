import 'package:url_launcher/url_launcher.dart';

/// Opens the WhatsApp chat of [phone] (international digits, no "+")
/// with [message] already typed. Returns false if WhatsApp could not open.
Future<bool> openWhatsAppChat({required String phone, required String message}) async {
  final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
  try {
    return await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
  } catch (_) {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
