import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/notification_service.dart';
import '../domain/repositories/transaction_repository.dart';
import 'repository_providers.dart';
import 'budget_provider.dart';

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<BudgetTransaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(ref, repo);
});

final transactionSearchQueryProvider = StateProvider<String>((ref) => '');

final transactionTypeFilterProvider = StateProvider<TransactionType?>((ref) => null);

final filteredTransactionsProvider = Provider<List<BudgetTransaction>>((ref) {
  final transactions = ref.watch(transactionProvider);
  final query = ref.watch(transactionSearchQueryProvider).toLowerCase();
  final typeFilter = ref.watch(transactionTypeFilterProvider);

  return transactions.where((tx) {
    final matchesQuery = tx.senderOrReceiver.toLowerCase().contains(query) ||
                         tx.category.toLowerCase().contains(query) ||
                         tx.amount.toString().contains(query);
    final matchesType = typeFilter == null || tx.type == typeFilter;
    return matchesQuery && matchesType;
  }).toList();
});

class TransactionNotifier extends StateNotifier<List<BudgetTransaction>> {
  final Ref _ref;
  final TransactionRepository _repository;

  TransactionNotifier(this._ref, this._repository) : super([]) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = await _repository.getAllTransactions();
  }

  Future<void> refresh() async {
    await loadTransactions();
    await checkBudgets();
  }

  Future<void> addManualTransaction(BudgetTransaction tx) async {
    await _repository.saveTransactions([tx]);
    await loadTransactions();
    await checkBudgets();
  }

  Future<void> updateCategory(int dbId, String newCategory) async {
    await _repository.updateTransactionCategory(dbId, newCategory);
    await loadTransactions();
    await checkBudgets();
  }

  Future<void> checkBudgets() async {
    final budgets = _ref.read(budgetProvider);
    final now = DateTime.now();

    final currentMonthTransactions = state.where((tx) =>
        tx.timestamp.year == now.year && tx.timestamp.month == now.month).toList();

    final Map<String, double> spendByCategory = {};
    for (var tx in currentMonthTransactions) {
      if (tx.type == TransactionType.debit) {
        spendByCategory[tx.category] = (spendByCategory[tx.category] ?? 0) + tx.amount;
      }
    }

    for (var budget in budgets) {
      final spent = spendByCategory[budget.category] ?? 0.0;
      final percentage = budget.limitAmount > 0 ? (spent / budget.limitAmount) : 0.0;

      if (percentage >= 1.0) {
        NotificationService.showBudgetAlert(budget.category, 1.0);
      } else if (percentage >= 0.8) {
        NotificationService.showBudgetAlert(budget.category, 0.8);
      }
    }
  }
}
