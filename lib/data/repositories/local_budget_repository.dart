import '../../domain/repositories/budget_repository.dart';
import '../../models/budget.dart';
import '../../services/storage_service.dart';

class LocalBudgetRepository implements BudgetRepository {
  @override
  Future<List<Budget>> getAllBudgets() async {
    return await StorageService.getAllBudgetsAsync();
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    await StorageService.saveBudget(budget);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await StorageService.deleteBudget(id);
  }
}
