import 'package:flutter_test/flutter_test.dart';
import 'package:budget_boss/services/storage_service.dart';
import 'package:budget_boss/models/transaction.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide BudgetTransaction;

void main() {
  setUpAll(() {
    // Use in-memory SQLite for tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Save transactions deduplication test', () async {
    final tx1 = BudgetTransaction(
      id: 'TX123',
      amount: 100.0,
      type: TransactionType.debit,
      category: 'Food',
      timestamp: DateTime.now(),
      senderOrReceiver: 'Restaurant',
      rawMessage: 'Message 1',
    );

    final tx2 = BudgetTransaction(
      id: 'TX123', // Same ID — should be deduplicated
      amount: 100.0,
      type: TransactionType.debit,
      category: 'Food',
      timestamp: DateTime.now(),
      senderOrReceiver: 'Restaurant',
      rawMessage: 'Message 2 (Updated)',
    );

    await StorageService.saveTransactions([tx1, tx2]);

    final allTxs = await StorageService.getAllTransactions();
    expect(allTxs.length, 1);
    expect(allTxs.first.rawMessage, 'Message 1'); // Should keep the first one
  });
}
