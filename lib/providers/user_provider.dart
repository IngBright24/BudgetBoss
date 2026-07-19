import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<User?> {
  final Ref _ref;
  
  UserNotifier(this._ref) : super(StorageService.getUser());

  Future<void> register({
    required String name,
    required String phone,
  }) async {
    final user = User(
      name: name,
      phone: phone,
      registrationDate: DateTime.now(),
      pin: '', // Pin is now stored in flutter_secure_storage
    );
    
    // Persist to Hive
    await StorageService.saveUser(user);
    
    // Update Navigation States
    await StorageService.setExplicitlyLoggedOut(false);
    await StorageService.setLoggedIn(true);
    
    state = user;
  }

  void refreshUser() {
    state = StorageService.getUser();
  }
}
