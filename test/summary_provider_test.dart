import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_boss/providers/transaction_provider.dart';
import 'package:budget_boss/providers/budget_provider.dart';
import 'package:budget_boss/providers/summary_provider.dart';
import 'package:budget_boss/models/transaction.dart';
import 'package:budget_boss/models/budget.dart';
import 'package:budget_boss/domain/repositories/budget_repository.dart';
import 'package:budget_boss/domain/repositories/transaction_repository.dart';

void main() {
  test('SummaryProvider calculations test', () {
    final container = ProviderContainer(
      overrides: [
        transactionProvider.overrideWith((ref) => TransactionNotifierMock([
          BudgetTransaction(
            id: '1',
            amount: 50.0,
            type: TransactionType.debit,
            category: 'Food',
            timestamp: DateTime.now(),
            senderOrReceiver: 'Vendor',
            rawMessage: 'Food msg',
          ),
          BudgetTransaction(
            id: '2',
            amount: 30.0,
            type: TransactionType.debit,
            category: 'Food',
            timestamp: DateTime.now(),
            senderOrReceiver: 'Vendor',
            rawMessage: 'Food msg 2',
          ),
          BudgetTransaction(
            id: '3',
            amount: 100.0,
            type: TransactionType.debit,
            category: 'Transport',
            timestamp: DateTime.now(),
            senderOrReceiver: 'Uber',
            rawMessage: 'Uber msg',
          ),
        ])),
        budgetProvider.overrideWith((ref) => BudgetNotifierMock([
          Budget(category: 'Food', limitAmount: 100.0, period: 'monthly'),
          Budget(category: 'Transport', limitAmount: 50.0, period: 'monthly'),
        ])),
      ],
    );

    final summary = container.read(summaryProvider);
    final totalSpent = summary['totalSpent'] as double;
    final summaries = summary['summaries'] as List<CategorySummary>;

    expect(totalSpent, 180.0);

    final foodSummary = summaries.firstWhere((s) => s.category == 'Food');
    expect(foodSummary.spent, 80.0);
    expect(foodSummary.percentage, 0.8);

    final transportSummary = summaries.firstWhere((s) => s.category == 'Transport');
    expect(transportSummary.spent, 100.0);
    expect(transportSummary.percentage, 2.0);
  });
}

class MockTxRepo implements TransactionRepository {
  @override
  Future<List<BudgetTransaction>> getAllTransactions() async => [];
  @override
  Future<void> saveTransactions(List<BudgetTransaction> transactions) async {}
  @override
  Future<void> updateTransactionCategory(int dbId, String newCategory) async {}
}

class TransactionNotifierMock extends TransactionNotifier {
  TransactionNotifierMock(List<BudgetTransaction> initial) : super(FakeRef(), MockTxRepo()) {
    state = initial;
  }

  @override
  Future<void> loadTransactions() async {}

  @override
  Future<void> checkBudgets() async {}
}

class MockBudgetRepo implements BudgetRepository {
  @override
  Future<List<Budget>> getAllBudgets() async => [];
  @override
  Future<void> saveBudget(Budget budget) async {}
  @override
  Future<void> deleteBudget(String id) async {}
}

class BudgetNotifierMock extends BudgetNotifier {
  BudgetNotifierMock(List<Budget> initial) : super(MockBudgetRepo()) {
    state = initial;
  }

  @override
  Future<void> loadBudgets() async {}
}

class FakeRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
