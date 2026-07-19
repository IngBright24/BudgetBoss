import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/currency_provider.dart';
import '../../models/transaction.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Map<int, double> monthlyIncome = {};
    final Map<int, double> monthlyExpenses = {};
    
    final now = DateTime.now();
    for (var i = 0; i < 6; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthKey = monthDate.month;
      monthlyIncome[monthKey] = 0;
      monthlyExpenses[monthKey] = 0;

      for (var tx in transactions) {
        if (tx.timestamp.month == monthKey && tx.timestamp.year == monthDate.year) {
          if (tx.type == TransactionType.credit) {
            monthlyIncome[monthKey] = (monthlyIncome[monthKey] ?? 0) + tx.amount;
          } else {
            monthlyExpenses[monthKey] = (monthlyExpenses[monthKey] ?? 0) + tx.amount;
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Reports', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Income vs Expenses', 
              style: GoogleFonts.poppins(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              )
            ),
            const SizedBox(height: 24),
            _buildBarChart(context, monthlyIncome, monthlyExpenses),
            const SizedBox(height: 40),
            _buildSummaryCards(context, monthlyIncome, monthlyExpenses, currency),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, Map<int, double> income, Map<int, double> expenses) {
    final months = income.keys.toList().reversed.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxValue(income, expenses) * 1.2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Text(
                      _getMonthName(months[value.toInt()]), 
                      style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black54)
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(months.length, (i) {
            final month = months[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: income[month] ?? 0, color: const Color(0xFF10B981), width: 12),
                BarChartRodData(toY: expenses[month] ?? 0, color: const Color(0xFFEF4444), width: 12),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, Map<int, double> income, Map<int, double> expenses, Currency currency) {
    double totalIncome = 0;
    double totalExpenses = 0;
    for (var v in income.values) { totalIncome += v; }
    for (var v in expenses.values) { totalExpenses += v; }

    return Column(
      children: [
        _SummaryCard(title: 'Average Monthly Income', amount: totalIncome / 6, color: const Color(0xFF10B981), currency: currency),
        const SizedBox(height: 16),
        _SummaryCard(title: 'Average Monthly Spend', amount: totalExpenses / 6, color: const Color(0xFFEF4444), currency: currency),
      ],
    );
  }

  double _getMaxValue(Map<int, double> map1, Map<int, double> map2) {
    double max = 0;
    for (var v in map1.values) { if (v > max) max = v; }
    for (var v in map2.values) { if (v > max) max = v; }
    return max == 0 ? 1000 : max;
  }

  String _getMonthName(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final Currency currency;
  const _SummaryCard({required this.title, required this.amount, required this.color, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text('${currency.symbol}${amount.toStringAsFixed(0)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }
}
