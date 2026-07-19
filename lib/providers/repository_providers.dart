import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/transaction_repository.dart';
import '../domain/repositories/budget_repository.dart';
import '../domain/repositories/goal_repository.dart';
import '../domain/repositories/bill_repository.dart';
import '../domain/repositories/wallet_repository.dart';

import '../data/repositories/local_transaction_repository.dart';
import '../data/repositories/local_budget_repository.dart';
import '../data/repositories/local_goal_repository.dart';
import '../data/repositories/local_bill_repository.dart';
import '../data/repositories/local_wallet_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return LocalTransactionRepository();
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return LocalBudgetRepository();
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return LocalGoalRepository();
});

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return LocalBillRepository();
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return LocalWalletRepository();
});
