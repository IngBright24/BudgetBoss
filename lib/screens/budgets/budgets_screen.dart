import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/budget_provider.dart';
import '../../providers/currency_provider.dart';
import '../../models/budget.dart';
import '../../providers/summary_provider.dart';
import 'package:share_plus/share_plus.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  void _showGlobalBudgetDialog(BuildContext context, WidgetRef ref, Currency currency, {double? currentLimit}) {
    final controller = TextEditingController(text: currentLimit?.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Global Limit (${currency.code})'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              ref.read(budgetProvider.notifier).setGlobalBudget(amount);
              Navigator.pop(context);
            },
            child: const Text('Set Budget'),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref, Currency currency) {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category (e.g., Food, Transport)'),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Monthly Limit (${currency.code})'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final budget = Budget(
                category: categoryController.text,
                limitAmount: double.tryParse(amountController.text) ?? 0.0,
                period: 'monthly',
              );
              ref.read(budgetProvider.notifier).saveBudget(budget);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetProvider);
    final globalBudget = ref.read(budgetProvider.notifier).getGlobalBudget();
    final summaryMap = ref.watch(summaryProvider);
    final List<CategorySummary> summaries = summaryMap['summaries'] as List<CategorySummary>;
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgeting', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlobalBudgetCard(context, ref, globalBudget, currency),
            const SizedBox(height: 32),
            const Text('Category Budgets',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 16),
            if (summaries.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text('No category budgets set.', 
                    style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400])
                  ),
                ),
              )
            else
              ...summaries.map((summary) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: summary.percentage >= 0.8 
                    ? BorderSide(color: summary.percentage >= 1.0 ? Colors.red : Colors.orange, width: 2)
                    : BorderSide.none,
                ),
                child: ListTile(
                  leading: const Icon(Icons.pie_chart, color: Color(0xFF06B6D4)),
                  title: Text(summary.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${currency.symbol}${summary.spent.toStringAsFixed(0)} spent of ${currency.symbol}${summary.limit.toStringAsFixed(0)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (summary.percentage >= 0.8)
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.blue),
                          onPressed: () {
                            final alertMsg = summary.percentage >= 1.0 
                              ? '🚨 Budget Alert: We have reached 100% of our ${summary.category} budget!'
                              : '⚠️ Budget Alert: We have reached ${(summary.percentage * 100).toStringAsFixed(0)}% of our ${summary.category} budget.';
                            Share.share(alertMsg);
                          },
                        ),
                      Text('${(summary.percentage * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: summary.percentage >= 1.0 ? Colors.red : (summary.percentage >= 0.8 ? Colors.orange : Colors.green),
                          )),
                    ],
                  ),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Budget?'),
                        content: Text('Remove limit for ${summary.category}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              final budgetId = budgets.firstWhere((b) => b.category == summary.category).id;
                              ref.read(budgetProvider.notifier).deleteBudget(budgetId);
                              Navigator.pop(context);
                            },
                            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context, ref, currency),
        backgroundColor: const Color(0xFF06B6D4),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGlobalBudgetCard(BuildContext context, WidgetRef ref, Budget? global, Currency currency) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Global Monthly Budget',
                  style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF06B6D4)),
                onPressed: () => _showGlobalBudgetDialog(context, ref, currency, currentLimit: global?.limitAmount),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${currency.code} ${global?.limitAmount.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('This is your total target spend for all categories combined.',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
