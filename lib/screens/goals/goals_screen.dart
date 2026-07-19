import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/goal_provider.dart';
import '../../providers/currency_provider.dart';
import '../../models/savings_goal.dart';
import 'package:uuid/uuid.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  void _showAddGoalDialog(BuildContext context, WidgetRef ref, Currency currency) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Savings Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Goal Title (e.g., New Laptop)'),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Target Amount (${currency.code})'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final goal = SavingsGoal(
                id: const Uuid().v4(),
                title: titleController.text,
                targetAmount: double.tryParse(amountController.text) ?? 0.0,
                currentAmount: 0.0,
                deadline: DateTime.now().add(const Duration(days: 30)),
                isCompleted: false,
              );
              ref.read(goalProvider.notifier).saveGoal(goal);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showContributionDialog(BuildContext context, WidgetRef ref, SavingsGoal goal, Currency currency) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save for ${goal.title}'),
        content: TextField(
          controller: amountController,
          decoration: InputDecoration(labelText: 'Amount (${currency.code})'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount > 0) {
                ref.read(goalProvider.notifier).addContribution(goal.id, amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Saved ${currency.code} ${amount.toStringAsFixed(2)} to ${goal.title}')),
                );
              }
            },
            child: const Text('Add to Savings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_outlined, size: 64, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No goals set', style: TextStyle(color: Colors.grey[500], fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final progress = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount) : 0.0;
                final isDone = goal.isCompleted || progress >= 1.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111827) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDone ? const Color(0xFF10B981).withValues(alpha: 0.5) : (isDark ? Colors.white10 : Colors.grey.shade200)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFF06B6D4).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(isDone ? Icons.check_circle : Icons.savings, 
                                  color: isDone ? const Color(0xFF10B981) : const Color(0xFF06B6D4)),
                    ),
                    title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Target: ${currency.symbol}${goal.targetAmount.toStringAsFixed(0)}',
                            style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(isDone ? const Color(0xFF10B981) : const Color(0xFF06B6D4)),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: isDone ? const Color(0xFF10B981) : const Color(0xFF06B6D4), 
                                fontSize: 16)),
                        Text(isDone ? 'COMPLETED' : 'SAVED', style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                    onTap: isDone ? null : () => _showContributionDialog(context, ref, goal, currency),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context, ref, currency),
        backgroundColor: const Color(0xFF06B6D4),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
