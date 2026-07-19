import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/savings_goal.dart';
import '../models/transaction.dart';
import '../services/notification_service.dart';
import '../domain/repositories/goal_repository.dart';
import 'repository_providers.dart';
import 'wallet_provider.dart';
import 'transaction_provider.dart';

final goalProvider = StateNotifierProvider<GoalNotifier, List<SavingsGoal>>((ref) {
  final repo = ref.watch(goalRepositoryProvider);
  return GoalNotifier(ref, repo);
});

class GoalNotifier extends StateNotifier<List<SavingsGoal>> {
  final Ref _ref;
  final GoalRepository _repository;

  GoalNotifier(this._ref, this._repository) : super([]) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    state = await _repository.getAllGoals();
  }

  Future<void> saveGoal(SavingsGoal goal) async {
    await _repository.saveGoal(goal);
    await loadGoals();
  }

  Future<void> addContribution(String goalId, double amount) async {
    final goalIndex = state.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) return;

    final goal = state[goalIndex];
    if (goal.isCompleted) return;

    double newCurrentAmount = goal.currentAmount + amount;
    bool isNowCompleted = newCurrentAmount >= goal.targetAmount;

    // Cap at target amount
    if (isNowCompleted) {
      newCurrentAmount = goal.targetAmount;
    }

    final updatedGoal = SavingsGoal(
      id: goal.id,
      title: goal.title,
      targetAmount: goal.targetAmount,
      currentAmount: newCurrentAmount,
      deadline: goal.deadline,
      isCompleted: isNowCompleted,
    );

    // 1. Update Goal in SQLite
    await _repository.updateGoal(updatedGoal);

    // 2. Create a BudgetTransaction for the activity feed
    final tx = BudgetTransaction(
      id: 'GOAL_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      type: TransactionType.debit,
      category: 'Savings',
      timestamp: DateTime.now(),
      senderOrReceiver: 'Goal: ${goal.title}',
      rawMessage: isNowCompleted ? 'Goal "${goal.title}" Completed!' : 'Contribution to savings goal',
    );
    await _ref.read(transactionProvider.notifier).addManualTransaction(tx);

    // 3. Deduct from Wallet
    await _ref.read(walletProvider.notifier).recordExpense(amount);

    if (isNowCompleted) {
      NotificationService.showGoalCompleted(goal.title);
    }

    await loadGoals();
  }
}
