import 'package:another_telephony/telephony.dart';
import '../repository/sms_repository.dart';
import 'package:flutter/foundation.dart';

class SmsListener {
  final SmsRepository _smsRepository;
  final VoidCallback? onNewTransaction;

  SmsListener(this._smsRepository, {this.onNewTransaction});

  void startListening() async {
    debugPrint('SmsListener: Starting to listen for incoming SMS...');
    
    bool? permissionsGranted = await Telephony.instance.requestPhoneAndSmsPermissions;
    print("SMS_DEBUG >>> Listener registered: true, Permission granted: $permissionsGranted");

    Telephony.instance.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        print("SMS_DEBUG >>> sender: ${message.address} | body: ${message.body}");
        final body = message.body;
        if (body != null) {
          int rawDate = message.date ?? DateTime.now().millisecondsSinceEpoch;
          // If the date is absurdly small (before 2001 in ms), it's likely in seconds.
          if (rawDate < 1000000000000) {
            rawDate *= 1000;
          }
          final timestamp = DateTime.fromMillisecondsSinceEpoch(rawDate);
          await _smsRepository.processAndSaveSms(body, message.address ?? 'Unknown', timestamp);
        }
        
        if (onNewTransaction != null) {
          onNewTransaction!();
        }
      },
      onBackgroundMessage: backgroundMessageHandler,
    );
  }
}

@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(SmsMessage message) async {
  print("SMS_DEBUG >>> [BACKGROUND] sender: ${message.address} | body: ${message.body}");
}
