import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_boss/screens/dashboard/dashboard_screen.dart';
import 'package:budget_boss/providers/transaction_provider.dart';
import 'package:budget_boss/providers/budget_provider.dart';
import 'package:budget_boss/models/transaction.dart';
import 'package:budget_boss/models/budget.dart';
import 'package:budget_boss/domain/repositories/budget_repository.dart';
import 'package:budget_boss/domain/repositories/transaction_repository.dart';

void main() {
  testWidgets('Dashboard displays total spent and summary', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionProvider.overrideWith((ref) => TransactionNotifierMock([
            BudgetTransaction(
              id: '1',
              amount: 50.0,
              type: TransactionType.debit,
              category: 'Food',
              timestamp: DateTime.now(),
              senderOrReceiver: 'Vendor',
              rawMessage: 'msg',
            ),
          ])),
          budgetProvider.overrideWith((ref) => BudgetNotifierMock([
            Budget(category: 'Food', limitAmount: 100.0, period: 'monthly'),
          ])),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify total spent
    expect(find.text('GHS 50.00'), findsOneWidget);

    // Verify budget progress bar text
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('GHS 50 / 100'), findsOneWidget);
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
