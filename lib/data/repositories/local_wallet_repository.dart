import '../../domain/repositories/wallet_repository.dart';
import '../../models/wallet.dart';
import '../../services/storage_service.dart';

class LocalWalletRepository implements WalletRepository {
  @override
  Future<Wallet> getWallet() async {
    return await StorageService.getWalletAsync();
  }

  @override
  Future<void> saveWallet(Wallet wallet) async {
    await StorageService.saveWallet(wallet);
  }
}
