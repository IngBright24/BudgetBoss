import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bill.dart';
import '../models/transaction.dart';
import '../services/notification_service.dart';
import '../domain/repositories/bill_repository.dart';
import 'repository_providers.dart';
import 'wallet_provider.dart';
import 'transaction_provider.dart';

final billProvider = StateNotifierProvider<BillNotifier, List<Bill>>((ref) {
  final repo = ref.watch(billRepositoryProvider);
  return BillNotifier(ref, repo);
});

class BillNotifier extends StateNotifier<List<Bill>> {
  final Ref _ref;
  final BillRepository _repository;

  BillNotifier(this._ref, this._repository) : super([]) {
    _init();
  }

  Future<void> _init() async {
    await loadBills();
    _checkReminders();
    await _checkAutoDeductions();
  }

  Future<void> loadBills() async {
    state = await _repository.getAllBills();
  }

  void _checkReminders() {
    final now = DateTime.now();
    for (var bill in state) {
      if (!bill.isPaid) {
        final difference = bill.dueDate.difference(now).inDays;
        if (difference >= 0 && difference <= 1) {
          NotificationService.showBillReminder(bill.name, bill.dueDate);
        }
      }
    }
  }

  Future<void> _checkAutoDeductions() async {
    final now = DateTime.now();
    bool updated = false;

    for (var bill in state) {
      if (bill.isRecurring && !bill.isPaid) {
        final lastPaid = bill.lastPaidDate;
        final isDifferentMonth = lastPaid == null ||
            (lastPaid.month != now.month || lastPaid.year != now.year);

        if (isDifferentMonth && now.day >= bill.dueDate.day) {
          await togglePaid(bill.id);
          updated = true;
        }
      }
    }
    if (updated) {
      await loadBills();
    }
  }

  Future<void> saveBill(Bill bill) async {
    await _repository.saveBill(bill);
    await loadBills();
    _checkReminders();
  }

  Future<void> deleteBill(String id) async {
    await _repository.deleteBill(id);
    await loadBills();
  }

  Future<void> togglePaid(String id) async {
    final billIndex = state.indexWhere((b) => b.id == id);
    if (billIndex == -1) return;

    final bill = state[billIndex];
    final bool newPaidStatus = !bill.isPaid;

    final updatedBill = Bill(
      id: bill.id,
      name: bill.name,
      amount: bill.amount,
      dueDate: bill.dueDate,
      category: bill.category,
      notes: bill.notes,
      isPaid: newPaidStatus,
      isRecurring: bill.isRecurring,
      lastPaidDate: newPaidStatus ? DateTime.now() : bill.lastPaidDate,
    );

    await _repository.updateBill(updatedBill);

    if (newPaidStatus) {
      final tx = BudgetTransaction(
        id: 'BILL_${DateTime.now().millisecondsSinceEpoch}',
        amount: bill.amount,
        type: TransactionType.debit,
        category: bill.category,
        timestamp: DateTime.now(),
        senderOrReceiver: 'Bill: ${bill.name}',
        rawMessage: 'Payment for ${bill.name}',
      );
      await _ref.read(transactionProvider.notifier).addManualTransaction(tx);
      await _ref.read(walletProvider.notifier).recordExpense(bill.amount);
      NotificationService.showBillPaid(bill.name);
    }

    await loadBills();
  }
}
