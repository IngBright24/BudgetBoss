import '../../domain/repositories/transaction_repository.dart';
import '../../models/transaction.dart';
import '../../services/storage_service.dart';
import '../../database/sqlite_helper.dart';

class LocalTransactionRepository implements TransactionRepository {
  @override
  Future<List<BudgetTransaction>> getAllTransactions() async {
    return await StorageService.getAllTransactions();
  }

  @override
  Future<void> saveTransactions(List<BudgetTransaction> transactions) async {
    await StorageService.saveTransactions(transactions);
  }

  @override
  Future<void> updateTransactionCategory(int dbId, String newCategory) async {
    await SQLiteHelper.instance.updateTransactionCategory(dbId, newCategory);
  }
}
