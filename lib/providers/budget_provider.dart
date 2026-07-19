import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget.dart';
import '../domain/repositories/budget_repository.dart';
import 'repository_providers.dart';

final budgetProvider = StateNotifierProvider<BudgetNotifier, List<Budget>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return BudgetNotifier(repo);
});

class BudgetNotifier extends StateNotifier<List<Budget>> {
  final BudgetRepository _repository;

  BudgetNotifier(this._repository) : super([]) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    state = await _repository.getAllBudgets();
  }

  Future<void> saveBudget(Budget budget) async {
    await _repository.saveBudget(budget);
    await loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _repository.deleteBudget(id);
    await loadBudgets();
  }

  Budget? getGlobalBudget() {
    try {
      return state.firstWhere((b) => b.isGlobal);
    } catch (e) {
      return null;
    }
  }

  Future<void> setGlobalBudget(double amount) async {
    // If a global budget already exists, reuse its id to replace it
    final existing = getGlobalBudget();
    final globalBudget = Budget(
      id: existing?.id,
      category: 'Global',
      limitAmount: amount,
      period: 'monthly',
      isGlobal: true,
    );
    await saveBudget(globalBudget);
  }
}
