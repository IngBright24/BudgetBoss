import 'package:flutter/foundation.dart';
import '../../database/sqlite_helper.dart';
import '../models/sms_transaction_model.dart';
import '../parser/sms_parser.dart';
import '../../services/notification_service.dart';
import '../repositories/category_rule_repository.dart';

class SmsRepository {
  final SQLiteHelper _dbHelper = SQLiteHelper.instance;
  final CategoryRuleRepository _categoryRuleRepo = CategoryRuleRepository();

  Future<void> processAndSaveSms(String rawSms, String senderNumber, DateTime timestamp) async {
    // 1. Fetch custom category rules
    final customRules = await _categoryRuleRepo.getAllRules();

    // 2. Parse SMS
    final parsedModel = SmsParser.parse(rawSms, senderNumber, timestamp, customRules: customRules);
    if (parsedModel == null) return; // Should not happen with new parser

    if (parsedModel.type == 'Needs Review') {
      debugPrint('SmsRepository: SMS from $senderNumber needs review. Body: $rawSms. Saving for later.');
    } else {
      debugPrint('SmsRepository: SMS successfully parsed as ${parsedModel.type} of amount ${parsedModel.amount}.');
    }

    // 2. Check for Duplicates (ALWAYS check, even if unparsed, using the rawSms fallback)
    final isDuplicate = await _dbHelper.isDuplicate(parsedModel);
    if (isDuplicate) {
      debugPrint('Duplicate SMS detected. Ignoring.');
      return;
    }

    // 3. Save to SQLite
    await _dbHelper.insertTransaction(parsedModel);

    // 4. Trigger Notification
    if (parsedModel.type != 'Needs Review') {
      final merchantOrSender = parsedModel.merchant ?? parsedModel.sender ?? parsedModel.receiver ?? 'Unknown';
      await NotificationService.showSmsTransactionAlert(
        parsedModel.type,
        parsedModel.amount,
        parsedModel.currency,
        parsedModel.category,
        merchantOrSender,
      );
    }
  }

  Future<List<SmsTransactionModel>> getStoredTransactions() async {
    return await _dbHelper.getAllTransactions();
  }
}
