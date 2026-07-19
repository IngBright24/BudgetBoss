import '../../domain/repositories/goal_repository.dart';
import '../../models/savings_goal.dart';
import '../../services/storage_service.dart';

class LocalGoalRepository implements GoalRepository {
  @override
  Future<List<SavingsGoal>> getAllGoals() async {
    return await StorageService.getAllGoalsAsync();
  }

  @override
  Future<void> saveGoal(SavingsGoal goal) async {
    await StorageService.saveGoal(goal);
  }

  @override
  Future<void> updateGoal(SavingsGoal goal) async {
    await StorageService.updateGoal(goal);
  }
}
