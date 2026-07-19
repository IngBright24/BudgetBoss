import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet.dart';
import '../services/notification_service.dart';
import '../domain/repositories/wallet_repository.dart';
import 'repository_providers.dart';
import 'currency_provider.dart';
import '../models/transaction.dart';

final walletProvider = StateNotifierProvider<WalletNotifier, Wallet>((ref) {
  final repo = ref.watch(walletRepositoryProvider);
  return WalletNotifier(ref, repo);
});

class WalletNotifier extends StateNotifier<Wallet> {
  final Ref _ref;
  final WalletRepository _repository;

  WalletNotifier(this._ref, this._repository) : super(Wallet()) {
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    state = await _repository.getWallet();
  }

  Future<void> reload() async {
    state = await _repository.getWallet();
  }

  Future<void> deposit(double amount) async {
    final updated = Wallet(
      balance: state.balance + amount,
      totalDeposits: state.totalDeposits + amount,
      totalExpenses: state.totalExpenses,
    );
    await _repository.saveWallet(updated);
    state = updated;

    final currency = _ref.read(currencyProvider);
    NotificationService.showDepositSuccess(amount, currency.code);
  }

  Future<void> recordExpense(double amount) async {
    final updated = Wallet(
      balance: state.balance - amount,
      totalDeposits: state.totalDeposits,
      totalExpenses: state.totalExpenses + amount,
    );
    await _repository.saveWallet(updated);
    state = updated;
  }

  Future<void> reset() async {
    final empty = Wallet();
    await _repository.saveWallet(empty);
    state = empty;
  }

  Future<void> recalculateFrom(List<BudgetTransaction> transactions) async {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.credit) {
        totalIncome += tx.amount;
      } else if (tx.type == TransactionType.debit) {
        totalExpense += tx.amount;
      }
    }

    final updated = Wallet(
      balance: totalIncome - totalExpense,
      totalDeposits: totalIncome,
      totalExpenses: totalExpense,
    );
    await _repository.saveWallet(updated);
    state = updated;
  }
}
