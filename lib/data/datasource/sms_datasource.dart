import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../../services/provider_detection_service.dart';

class SmsDataSource {
  final Telephony telephony = Telephony.instance;

  Future<bool> requestPermissions() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }
}
