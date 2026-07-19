import '../../models/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Future<void> saveBudget(Budget budget);
  Future<void> deleteBudget(String id);
}
