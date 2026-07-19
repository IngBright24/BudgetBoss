import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import 'budget_provider.dart';
import 'bill_provider.dart';
import '../models/transaction.dart';

class CategorySummary {
  final String category;
  final double spent;
  final double limit;
  final double percentage;

  CategorySummary({
    required this.category,
    required this.spent,
    required this.limit,
    required this.percentage,
  });
}

enum SummaryRange { daily, weekly, monthly }

final summaryRangeProvider = StateProvider<SummaryRange>((ref) => SummaryRange.monthly);

final summaryProvider = Provider((ref) {
  final transactions = ref.watch(transactionProvider);
  final budgets = ref.watch(budgetProvider);
  final bills = ref.watch(billProvider);
  final range = ref.watch(summaryRangeProvider);

  final now = DateTime.now();
  
  final List<BudgetTransaction> filteredTransactions = transactions.where((tx) {
    if (range == SummaryRange.daily) {
      return tx.timestamp.year == now.year && 
             tx.timestamp.month == now.month && 
             tx.timestamp.day == now.day;
    } else if (range == SummaryRange.weekly) {
      final weekAgo = now.subtract(const Duration(days: 7));
      return tx.timestamp.isAfter(weekAgo);
    } else {
      // Monthly
      return tx.timestamp.year == now.year && tx.timestamp.month == now.month;
    }
  }).toList();

  final Map<String, double> spendByCategory = {};
  double totalSpent = 0; // Same as period expenses
  double periodIncome = 0;
  
  // Calculate period income and expenses
  for (var tx in filteredTransactions) {
    if (tx.type == TransactionType.debit) {
      spendByCategory[tx.category] = (spendByCategory[tx.category] ?? 0) + tx.amount;
      totalSpent += tx.amount;
    } else if (tx.type == TransactionType.credit) {
      periodIncome += tx.amount;
    }
  }

  // Calculate lifetime balance
  double lifetimeBalance = 0;
  for (var tx in transactions) {
    if (tx.type == TransactionType.credit) {
      lifetimeBalance += tx.amount;
    } else if (tx.type == TransactionType.debit) {
      lifetimeBalance -= tx.amount;
    }
  }
  // Calculate global budget status
  final globalBudget = ref.read(budgetProvider.notifier).getGlobalBudget();
  double globalLimit = globalBudget?.limitAmount ?? 0.0;
  
  // Scale budget if range is not monthly
  if (range == SummaryRange.daily) {
    globalLimit = globalLimit / 30;
  } else if (range == SummaryRange.weekly) {
    globalLimit = globalLimit / 4.33; // Average weeks in a month
  }
  
  final globalPercentage = globalLimit > 0 ? (totalSpent / globalLimit) : 0.0;

  final List<CategorySummary> summaries = budgets.where((b) => !b.isGlobal).map((budget) {
    final spent = spendByCategory[budget.category] ?? 0.0;
    double limit = budget.limitAmount;
    
    // Scale category budget
    if (range == SummaryRange.daily) {
      limit = limit / 30;
    } else if (range == SummaryRange.weekly) {
      limit = limit / 4.33;
    }

    return CategorySummary(
      category: budget.category,
      spent: spent,
      limit: limit,
      percentage: limit > 0 ? (spent / limit) : 0.0,
    );
  }).toList();

  return {
    'totalSpent': totalSpent,
    'periodIncome': periodIncome,
    'lifetimeBalance': lifetimeBalance,
    'summaries': summaries,
    'spendByCategory': spendByCategory,
    'bills': bills,
    'globalLimit': globalLimit,
    'globalPercentage': globalPercentage,
    'range': range,
  };
});

