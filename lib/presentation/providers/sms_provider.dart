import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sms_transaction_model.dart';
import '../../data/repository/sms_repository.dart';
import '../../data/datasource/sms_datasource.dart';
import '../../database/sqlite_helper.dart';
import '../../providers/wallet_provider.dart';
import '../../data/repositories/category_rule_repository.dart';

final smsProvider = StateNotifierProvider<SmsNotifier, List<SmsTransactionModel>>((ref) {
  return SmsNotifier(ref);
});

class SmsNotifier extends StateNotifier<List<SmsTransactionModel>> {
  final Ref _ref;
  final SmsRepository _repository = SmsRepository();
  final SmsDataSource _dataSource = SmsDataSource();

  SmsNotifier(this._ref) : super([]) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final transactions = await _repository.getStoredTransactions();
    state = transactions;
  }

  Future<void> requestPermissions() async {
    final granted = await _dataSource.requestPermissions();
    if (!granted) return;
    // Permissions requested and granted. Listening for new SMS continues.
  }

  Future<void> addManualTestSms(String rawSms) async {
    await _repository.processAndSaveSms(rawSms, "TEST_BANK", DateTime.now());
    await loadTransactions();
    _recalculateWalletBasedOnSms();
  }

  /// Updates the category of a transaction both in SQLite and local state.
  Future<void> updateCategory(int id, String newCategory) async {
    await SQLiteHelper.instance.updateTransactionCategory(id, newCategory);
    
    // Find the transaction to learn from it
    final tx = state.firstWhere((t) => t.id == id);
    final counterparty = tx.merchant ?? tx.sender ?? tx.receiver;
    if (counterparty != null && counterparty.isNotEmpty) {
       final categoryRepo = CategoryRuleRepository();
       await categoryRepo.saveRule(counterparty, newCategory);
    }

    // Update in-memory state immediately — no need for a full DB reload
    state = state.map((tx) {
      if (tx.id == id) {
        return SmsTransactionModel(
          id: tx.id,
          amount: tx.amount,
          currency: tx.currency,
          type: tx.type,
          merchant: tx.merchant,
          sender: tx.sender,
          receiver: tx.receiver,
          date: tx.date,
          time: tx.time,
          reference: tx.reference,
          balance: tx.balance,
          category: newCategory,
          provider: tx.provider,
          rawSms: tx.rawSms,
          isParsed: tx.isParsed,
          createdAt: tx.createdAt,
        );
      }
      return tx;
    }).toList();
  }

  void _recalculateWalletBasedOnSms() {
    // Ideally we diff it, but for Phase 1 Demo Wallet Integration:
    // If we just got a new SMS, we apply it to the wallet.
    // Since loadTransactions loads everything, we only want to apply recent ones.
    // Let's just apply the most recent one if it's new, but actually
    // the requirement says: "The parser should automatically update it."
    
    if (state.isEmpty) return;
    
    final latest = state.first; // sorted by createdAt DESC
    // If it was just created (within last 5 seconds), update wallet
    if (DateTime.now().difference(latest.createdAt).inSeconds < 5) {
      if (latest.type == 'Income' || latest.type == 'Deposit') {
        _ref.read(walletProvider.notifier).deposit(latest.amount);
      } else if (latest.type == 'Expense' || latest.type == 'Withdrawal' || latest.type == 'Transfer') {
        _ref.read(walletProvider.notifier).recordExpense(latest.amount);
      }
    }
  }
}
