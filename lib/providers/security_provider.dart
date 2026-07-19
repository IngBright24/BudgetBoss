import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../services/storage_service.dart';

final securityProvider = StateNotifierProvider<SecurityNotifier, bool>((ref) {
  return SecurityNotifier(ref);
});

class SecurityNotifier extends StateNotifier<bool> {
  final Ref _ref;
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  
  SecurityNotifier(this._ref) : super(false) {
    _init();
  }

  Future<void> _init() async {
    // Check if the user is registered at all (local user exists)
    final user = StorageService.getUser();
    if (user == null) {
      // If no user is registered, there's no pin lock to enforce yet.
      state = true;
      return;
    }
    
    // Check if a PIN is set up. If no PIN is found in secure storage, 
    // it implies they haven't finished setup.
    final hasPin = await _storage.containsKey(key: 'user_pin');
    if (!hasPin) {
      state = true;
      return;
    }
    
    // Default to locked when the app starts.
    state = false;
  }

  /// Called when the app resumes from background
  void lockApp() {
    state = false;
  }

  /// Sets the initial PIN and recovery code hash
  Future<void> setupSecurity(String pin, String recoveryCode) async {
    await _storage.write(key: 'user_pin', value: pin);
    
    // Hash the recovery code before storing it
    final bytes = utf8.encode(recoveryCode);
    final digest = sha256.convert(bytes);
    await _storage.write(key: 'recovery_hash', value: digest.toString());
    
    state = true; // Unlock the app immediately after setup
  }

  /// Verifies the entered PIN
  Future<bool> verifyPin(String enteredPin) async {
    final storedPin = await _storage.read(key: 'user_pin');
    if (storedPin == enteredPin) {
      state = true;
      return true;
    }
    return false;
  }

  /// Verifies the recovery code
  Future<bool> verifyRecoveryCode(String enteredCode) async {
    final storedHash = await _storage.read(key: 'recovery_hash');
    if (storedHash == null) return false;
    
    final bytes = utf8.encode(enteredCode);
    final digest = sha256.convert(bytes);
    
    return storedHash == digest.toString();
  }

  /// Resets the PIN (requires verifying recovery code or biometric first)
  Future<void> resetPin(String newPin) async {
    await _storage.write(key: 'user_pin', value: newPin);
    state = true;
  }

  /// Attempts biometric authentication
  Future<bool> authenticateWithBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics && await _localAuth.isDeviceSupported();
      if (!isAvailable) return false;
      
      // Check if user has opted-in to biometrics (we store this in secure storage too)
      final biometricEnabled = await _storage.read(key: 'biometric_enabled');
      if (biometricEnabled != 'true') return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock BudgetBoss',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (authenticated) {
        state = true;
      }
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  /// Toggle biometric preference
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    return (await _storage.read(key: 'biometric_enabled')) == 'true';
  }
}
