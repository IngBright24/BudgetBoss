import 'package:flutter/widgets.dart';
import 'package:budget_boss/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dump db', () async {
    WidgetsFlutterBinding.ensureInitialized();
    await StorageService.init();
    final txs = await StorageService.getAllTransactions();
    print('--- TRANSACTION LOG ---');
    for (var tx in txs) {
      print('ID: '' Timestamp: '' Amount: '' Type: ''');
    }
    print('-----------------------');
  });
}
