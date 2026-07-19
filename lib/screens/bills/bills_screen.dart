import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/bill_provider.dart';
import '../../providers/currency_provider.dart';
import '../../models/bill.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  void _showBillDialog(BuildContext context, WidgetRef ref, Currency currency, {Bill? bill}) {
    final nameController = TextEditingController(text: bill?.name);
    final amountController = TextEditingController(text: bill?.amount.toString());
    DateTime selectedDate = bill?.dueDate ?? DateTime.now();
    String category = bill?.category ?? 'Utilities';
    bool isRecurring = bill?.isRecurring ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(bill == null ? 'Add Bill' : 'Edit Bill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Bill Name'),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount (${currency.code})'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Monthly Recurring'),
                  subtitle: const Text('Auto-pay on due date'),
                  value: isRecurring,
                  onChanged: (val) => setDialogState(() => isRecurring = val),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  items: ['Utilities', 'Rent', 'Subscription', 'Insurance', 'Other']
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
                final newBill = Bill(
                  id: bill?.id ?? const Uuid().v4(),
                  name: nameController.text,
                  amount: double.tryParse(amountController.text) ?? 0.0,
                  dueDate: selectedDate,
                  category: category,
                  isPaid: bill?.isPaid ?? false,
                  isRecurring: isRecurring,
                  lastPaidDate: bill?.lastPaidDate,
                );
                ref.read(billProvider.notifier).saveBill(newBill);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(bill == null ? 'Bill added' : 'Bill updated')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Bills', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: bills.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No bills added', style: TextStyle(color: Colors.grey[500], fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bills.length,
              itemBuilder: (context, index) {
                final bill = bills[index];
                final now = DateTime.now();
                // Check if due within 1 day and not paid
                final isDueSoon = !bill.isPaid && bill.dueDate.difference(now).inDays >= 0 && bill.dueDate.difference(now).inDays <= 1;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isDueSoon ? const BorderSide(color: Colors.orange, width: 2) : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: bill.isPaid ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      child: Icon(
                        bill.isPaid ? Icons.check_circle : Icons.pending_actions,
                        color: bill.isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(bill.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        if (bill.isRecurring)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('MONTHLY', style: TextStyle(fontSize: 8, color: Colors.blue, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    subtitle: Text('Due: ${DateFormat('MMM dd').format(bill.dueDate)} • ${bill.category}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDueSoon)
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.blue),
                            onPressed: () {
                              Share.share('⚠️ Upcoming Bill: Just a reminder that our ${bill.name} is due on ${DateFormat('MMM dd').format(bill.dueDate)}!');
                            },
                          ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${currency.symbol}${bill.amount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(bill.isPaid ? 'PAID' : 'UNPAID',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: bill.isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                )),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(bill.isPaid ? Icons.close : Icons.check_circle, color: bill.isPaid ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                              title: Text(bill.isPaid ? 'Mark as Unpaid' : 'Mark as Paid'),
                              onTap: () {
                                ref.read(billProvider.notifier).togglePaid(bill.id);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Edit Bill Details'),
                              onTap: () {
                                Navigator.pop(context);
                                _showBillDialog(context, ref, currency, bill: bill);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                              title: const Text('Delete Bill'),
                              onTap: () {
                                Navigator.pop(context);
                                ref.read(billProvider.notifier).deleteBill(bill.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBillDialog(context, ref, currency),
        backgroundColor: const Color(0xFF06B6D4),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
