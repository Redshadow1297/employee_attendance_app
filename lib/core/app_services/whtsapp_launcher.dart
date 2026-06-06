import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<void> sendMessage({
    required String phoneNumber,
    required String message,
  }) async {
    final encodedMessage = Uri.encodeComponent(message);

    final url = Platform.isAndroid
        ? 'https://wa.me/$phoneNumber?text=$encodedMessage'
        : 'https://api.whatsapp.com/send?phone=$phoneNumber&text=$encodedMessage';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'WhatsApp not installed';
    }
  }
}
