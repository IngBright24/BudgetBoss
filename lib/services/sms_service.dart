import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/parser/sms_parser.dart';
import 'storage_service.dart';
import '../models/transaction.dart';
import '../data/datasource/sms_datasource.dart';
import '../data/repository/sms_repository.dart';
import '../data/repositories/local_transaction_repository.dart';
import 'package:flutter/foundation.dart';
class SMSService {
  static final Telephony telephony = Telephony.instance;
  static final SmsDataSource _dataSource = SmsDataSource();
  static final SmsRepository _repository = SmsRepository();

  static Future<bool> requestPermissions() async {
    return await _dataSource.requestPermissions();
  }
}
