import '../../models/savings_goal.dart';

abstract class GoalRepository {
  Future<List<SavingsGoal>> getAllGoals();
  Future<void> saveGoal(SavingsGoal goal);
  Future<void> updateGoal(SavingsGoal goal);
}
