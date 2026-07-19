import '../../models/transaction.dart';

abstract class TransactionRepository {
  Future<List<BudgetTransaction>> getAllTransactions();
  Future<void> saveTransactions(List<BudgetTransaction> transactions);
  Future<void> updateTransactionCategory(int dbId, String newCategory);
}
