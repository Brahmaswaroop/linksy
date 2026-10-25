import 'package:url_launcher/url_launcher.dart';

class ContactActionHelper {
  /// Clean and normalize phone number for dialing/messaging
  static String normalizeNumber(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// Launch phone dialer
  static Future<bool> makeCall(String phoneNumber) async {
    final clean = normalizeNumber(phoneNumber);
    final uri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// Alias for makeCall
  static Future<bool> call(String phoneNumber) => makeCall(phoneNumber);

  /// Launch SMS app
  static Future<bool> sendSms(String phoneNumber) async {
    final clean = normalizeNumber(phoneNumber);
    final uri = Uri(scheme: 'sms', path: clean);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// Alias for sendSms
  static Future<bool> sms(String phoneNumber) => sendSms(phoneNumber);

  /// Launch WhatsApp chat
  static Future<bool> openWhatsApp(String phoneNumber) async {
    // Strip leading '+' or non-digit characters for WhatsApp web URL
    var clean = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Launch default email client
  static Future<bool> sendEmail(String email) async {
    final clean = email.trim();
    final uri = Uri(scheme: 'mailto', path: clean);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }
}

