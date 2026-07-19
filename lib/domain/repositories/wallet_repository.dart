import '../../models/wallet.dart';

abstract class WalletRepository {
  Future<Wallet> getWallet();
  Future<void> saveWallet(Wallet wallet);
}
