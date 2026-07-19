import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_boss/screens/budgets/budgets_screen.dart';
import 'package:budget_boss/providers/budget_provider.dart';
import 'package:budget_boss/models/budget.dart';
import 'package:budget_boss/domain/repositories/budget_repository.dart';

void main() {
  testWidgets('BudgetsScreen can open add budget dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetProvider.overrideWith((ref) => BudgetNotifierMock([])),
        ],
        child: const MaterialApp(home: BudgetsScreen()),
      ),
    );

    // Initial state: empty
    expect(find.text('No category budgets set.'), findsOneWidget);

    // Tap FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify dialog is open
    expect(find.text('Add Category Budget'), findsOneWidget);

    // Enter data
    await tester.enterText(find.byType(TextField).at(0), 'Food');
    await tester.enterText(find.byType(TextField).at(1), '500');

    // Tap Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify dialog is closed
    expect(find.text('Add Category Budget'), findsNothing);
  });
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

  @override
  Future<void> saveBudget(Budget budget) async {
    state = [...state, budget];
  }
}
