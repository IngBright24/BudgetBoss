import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/summary_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/ai_provider.dart';
import '../../models/savings_goal.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // Deposit dialog removed as it was for demo money only

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(summaryProvider);
    final goals = ref.watch(goalProvider);
    final currency = ref.watch(currencyProvider);
    final lifetimeBalance = summary['lifetimeBalance'] as double;
    final periodIncome = summary['periodIncome'] as double;
    final totalSpent = summary['totalSpent'] as double;
    final summaries = summary['summaries'] as List<CategorySummary>;
    final spendByCategory = summary['spendByCategory'] as Map<String, double>;
    final globalLimit = summary['globalLimit'] as double;
    final globalPercentage = summary['globalPercentage'] as double;
    final range = summary['range'] as SummaryRange;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(transactionProvider.notifier).refresh();
        ref.invalidate(aiInsightProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWalletCard(context, lifetimeBalance, periodIncome, totalSpent, ref, currency),
            const SizedBox(height: 24),
            _buildRangeSelector(ref, range),
            const SizedBox(height: 16),
            _buildSpendSummary(totalSpent, globalLimit, globalPercentage, range, currency),
            const SizedBox(height: 24),
            _buildAIInsightCard(ref),
            const SizedBox(height: 32),
            if (spendByCategory.isNotEmpty) ...[
              Text('${_getRangeLabel(range)} Breakdown',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const SizedBox(height: 24),
              _buildPieChart(context, spendByCategory),
              const SizedBox(height: 48),
            ],
            if (summaries.isNotEmpty) ...[
              Text('${_getRangeLabel(range)} Budgets',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const SizedBox(height: 16),
              ...summaries.map((s) => _buildBudgetProgress(context, s, currency)),
              const SizedBox(height: 32),
            ],
            if (goals.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Savings Goals',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
              const SizedBox(height: 12),
              ...goals.take(2).map((g) => _buildGoalCard(context, g, currency)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, double balance, double income, double expenses, WidgetRef ref, Currency currency) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Balance',
                  style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${currency.code} ${balance.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildWalletStat('Income', income, const Color(0xFF10B981), currency),
              const SizedBox(width: 24),
              _buildWalletStat('Expenses', expenses, const Color(0xFFEF4444), currency),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletStat(String label, double amount, Color color, Currency currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text('${currency.symbol}${amount.toStringAsFixed(0)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildRangeSelector(WidgetRef ref, SummaryRange selected) {
    return Center(
      child: SegmentedButton<SummaryRange>(
        segments: const [
          ButtonSegment(value: SummaryRange.daily, label: Text('Daily')),
          ButtonSegment(value: SummaryRange.weekly, label: Text('Weekly')),
          ButtonSegment(value: SummaryRange.monthly, label: Text('Monthly')),
        ],
        selected: {selected},
        onSelectionChanged: (val) {
          ref.read(summaryRangeProvider.notifier).state = val.first;
        },
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: const Color(0xFF06B6D4),
          selectedForegroundColor: Colors.white,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  String _getRangeLabel(SummaryRange range) {
    switch (range) {
      case SummaryRange.daily: return 'Daily';
      case SummaryRange.weekly: return 'Weekly';
      case SummaryRange.monthly: return 'Monthly';
    }
  }

  Widget _buildSpendSummary(double total, double limit, double percentage, SummaryRange range, Currency currency) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0891B2), const Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Total ${_getRangeLabel(range)} Spend',
              style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(
            '${currency.code} ${total.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
          if (limit > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage.clamp(0, 1),
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}% of ${currency.symbol}${limit.toStringAsFixed(0)} ${range.name} budget',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAIInsightCard(WidgetRef ref) {
    final aiState = ref.watch(aiInsightProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.analytics_outlined, color: Color(0xFF0369A1)),
          const SizedBox(width: 16),
          Expanded(
            child: aiState.when(
              data: (insight) => Text(
                insight,
                style: const TextStyle(color: Color(0xFF075985), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              loading: () => const Text(
                'Analyzing spending patterns...',
                style: TextStyle(color: Color(0xFF0369A1), fontSize: 13, fontStyle: FontStyle.italic),
              ),
              error: (e, _) => const Text(
                'Insights unavailable.',
                style: TextStyle(color: Color(0xFF7C2D12), fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, Map<String, double> data) {
    final List<PieChartSectionData> sections = data.entries.map((e) {
      final color = Colors.primaries[data.keys.toList().indexOf(e.key) % Colors.primaries.length];
      return PieChartSectionData(
        value: e.value,
        title: '',
        color: color,
        radius: 60,
        badgeWidget: _Badge(e.key, color: color),
        badgePositionPercentageOffset: 1.4,
      );
    }).toList();

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 4,
          centerSpaceRadius: 50,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildBudgetProgress(BuildContext context, CategorySummary s, Currency currency) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '${currency.symbol}${s.spent.toStringAsFixed(0)} / ${s.limit.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: s.percentage.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(
                s.percentage >= 1.0 ? const Color(0xFFEF4444) : (s.percentage >= 0.8 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
              ),
            ),
          ),
          if (s.percentage >= 0.8) 
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                s.percentage >= 1.0 ? 'Budget Exceeded!' : 'Approaching Limit',
                style: TextStyle(
                  color: s.percentage >= 1.0 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingsGoal goal, Currency currency) {
    final progress = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount) : 0.0;
    final isDone = goal.isCompleted || progress >= 1.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            Text('Target: ${currency.code} ${goal.targetAmount.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade600)),
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
                  fontSize: 16
                )),
            Text(isDone ? 'COMPLETED' : 'SAVED', style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
