import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'summary_provider.dart';
import 'currency_provider.dart';

// Use a StateNotifier so we can manually trigger a refresh of the Spending Insight
class AIInsightNotifier extends StateNotifier<AsyncValue<String>> {
  AIInsightNotifier(this.ref) : super(const AsyncValue.loading()) {
    generateInsight();
  }

  final Ref ref;

  Future<void> generateInsight() async {
    state = const AsyncValue.loading();
    try {
      final summary = ref.read(summaryProvider) as Map<String, dynamic>;
      final totalSpent = summary['totalSpent'] as double;
      final spendByCategory = summary['spendByCategory'] as Map<String, double>;
      final globalPercentage = summary['globalPercentage'] as double;
      final range = summary['range'] as SummaryRange;
      final currency = ref.read(currencyProvider);

      if (totalSpent == 0) {
        state = const AsyncValue.data("No spending recorded yet. Start tracking to see insights!");
        return;
      }

      // Local Statistical Analysis
      String insight = "";

      // 1. Identify Top Category
      final topCategory = spendByCategory.entries.fold(
        spendByCategory.entries.first, 
        (prev, element) => element.value > prev.value ? element : prev
      );

      insight += "Your top spending is in ${topCategory.key} (${currency.symbol}${topCategory.value.toStringAsFixed(0)}). ";

      // 2. Budget Health
      if (globalPercentage >= 1.0) {
        insight += "Warning: You've exceeded your ${_getRangeLabel(range)} budget!";
      } else if (globalPercentage >= 0.8) {
        insight += "Careful: You're at ${(globalPercentage * 100).toStringAsFixed(0)}% of your ${_getRangeLabel(range)} budget.";
      } else {
        insight += "You're at ${(globalPercentage * 100).toStringAsFixed(0)}% of your ${_getRangeLabel(range)} budget—keep it up!";
      }

      state = AsyncValue.data(insight);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String _getRangeLabel(SummaryRange range) {
    switch (range) {
      case SummaryRange.daily: return 'daily';
      case SummaryRange.weekly: return 'weekly';
      case SummaryRange.monthly: return 'monthly';
    }
  }
}

final aiInsightProvider = StateNotifierProvider<AIInsightNotifier, AsyncValue<String>>((ref) {
  // Watch summaryProvider to automatically update insights when data changes
  ref.watch(summaryProvider);
  return AIInsightNotifier(ref);
});
