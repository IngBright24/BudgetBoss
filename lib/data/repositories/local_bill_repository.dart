import '../../domain/repositories/bill_repository.dart';
import '../../models/bill.dart';
import '../../services/storage_service.dart';

class LocalBillRepository implements BillRepository {
  @override
  Future<List<Bill>> getAllBills() async {
    return await StorageService.getAllBillsAsync();
  }

  @override
  Future<void> saveBill(Bill bill) async {
    await StorageService.saveBill(bill);
  }

  @override
  Future<void> updateBill(Bill bill) async {
    await StorageService.updateBill(bill);
  }

  @override
  Future<void> deleteBill(String id) async {
    await StorageService.deleteBill(id);
  }
}
