import '../../models/bill.dart';

abstract class BillRepository {
  Future<List<Bill>> getAllBills();
  Future<void> saveBill(Bill bill);
  Future<void> updateBill(Bill bill);
  Future<void> deleteBill(String id);
}
