import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import 'package:intl/intl.dart';
import '../../providers/currency_provider.dart';
import '../../models/transaction.dart';
import '../../presentation/providers/sms_provider.dart';
import '../../data/parser/sms_parser.dart';
import '../../database/sqlite_helper.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  bool _isSyncing = false;

  void _showAddTransactionDialog(BuildContext context, Currency currency) {
    final amountController = TextEditingController();
    final recipientController = TextEditingController();
    String category = 'Food';
    TransactionType type = TransactionType.debit;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add BudgetTransaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(value: TransactionType.debit, label: Text('Expense'), icon: Icon(Icons.remove_circle_outline)),
                    ButtonSegment(value: TransactionType.credit, label: Text('Income'), icon: Icon(Icons.add_circle_outline)),
                  ],
                  selected: {type},
                  onSelectionChanged: (val) => setDialogState(() => type = val.first),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount (${currency.code})'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: recipientController,
                  decoration: const InputDecoration(labelText: 'Recipient/Sender'),
                ),
                if (type == TransactionType.debit)
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    items: ['Food', 'Transport', 'Data/Airtime', 'Bills', 'Other']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => category = val!,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                final tx = BudgetTransaction(
                  id: 'MANUAL_${DateTime.now().millisecondsSinceEpoch}',
                  amount: amount,
                  type: type,
                  category: type == TransactionType.credit ? 'Income' : category,
                  timestamp: DateTime.now(),
                  senderOrReceiver: recipientController.text,
                  rawMessage: 'Manually added',
                );
                ref.read(transactionProvider.notifier).addManualTransaction(tx);
                if (type == TransactionType.debit) {
                  ref.read(walletProvider.notifier).recordExpense(amount);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, BudgetTransaction tx) {
    if (tx.dbId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot recategorize this transaction.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Update Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: kAllCategories.length,
                  itemBuilder: (context, index) {
                    final cat = kAllCategories[index];
                    final isSelected = cat == tx.category;
                    return ListTile(
                      leading: Icon(_getCategoryIcon(cat), color: _getCategoryColor(cat)),
                      title: Text(cat, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF06B6D4)) : null,
                      onTap: () {
                        ref.read(transactionProvider.notifier).updateCategory(tx.dbId!, cat);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Category updated to $cat')),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final searchQuery = ref.watch(transactionSearchQueryProvider);
    final typeFilter = ref.watch(transactionTypeFilterProvider);
    final currency = ref.watch(currencyProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(context, currency),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) => ref.read(transactionSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search by name, amount, or category...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? const Color(0xFF111827) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: isDark ? BorderSide.none : const BorderSide(color: Colors.black12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', null, typeFilter == null),
                const SizedBox(width: 8),
                _buildFilterChip('Expenses', TransactionType.debit, typeFilter == TransactionType.debit),
                const SizedBox(width: 8),
                _buildFilterChip('Income', TransactionType.credit, typeFilter == TransactionType.credit),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty ? 'No history found' : 'No results matching "$searchQuery"',
                          style: TextStyle(color: Colors.grey[500], fontSize: 18),
                        ),
                          const SizedBox(height: 12),
                          Text(
                            'Waiting for new transactions...',
                            style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final isDebit = tx.type == TransactionType.debit;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF111827) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
                        ),
                        child: InkWell(
                          onTap: () => _showCategoryPicker(context, tx),
                          borderRadius: BorderRadius.circular(16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(tx.category).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getCategoryIcon(tx.category),
                                color: _getCategoryColor(tx.category),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              tx.senderOrReceiver,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              tx.rawMessage,
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              maxLines: 4,
                            ),
                            trailing: Text(
                              '${isDebit ? "-" : "+"} ${currency.symbol}${tx.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDebit
                                    ? (isDark ? const Color(0xFFEF4444) : Colors.black87)
                                    : const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionType? type, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => ref.read(transactionTypeFilterProvider.notifier).state = type,
      selectedColor: const Color(0xFFCFFAFE),
      checkmarkColor: const Color(0xFF06B6D4),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF06B6D4) : Colors.grey.shade600,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Transport': return Icons.directions_car;
      case 'Data/Airtime': return Icons.phone_android;
      case 'Bills': return Icons.receipt_long;
      case 'Income': return Icons.add_chart;
      case 'Savings': return Icons.savings;
      case 'Cash Out':
      case 'Cash Withdrawal': return Icons.account_balance_wallet;
      default: return Icons.shopping_bag;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return const Color(0xFFF59E0B);
      case 'Transport': return Colors.blue;
      case 'Data/Airtime': return Colors.purple;
      case 'Bills': return const Color(0xFFEF4444);
      case 'Income': return const Color(0xFF10B981);
      case 'Savings': return const Color(0xFF06B6D4);
      case 'Cash Out':
      case 'Cash Withdrawal': return Colors.brown;
      default: return Colors.blueGrey;
    }
  }
}
