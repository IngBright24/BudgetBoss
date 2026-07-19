import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/notification_preferences.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/bill.dart';
import '../models/wallet.dart';
import '../database/sqlite_helper.dart';

class StorageService {
  // ─── Hive box names (settings only) ───────────────────────────
  static const String settingsBoxName = 'settings';
  static const String userBoxName = 'user';
  static const String notificationPrefsBoxName = 'notification_prefs';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register only the adapters we still use in Hive
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(NotificationPreferencesAdapter());

    // Open lightweight Hive boxes
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<NotificationPreferences>(notificationPrefsBoxName);

    try {
      await Hive.openBox<User>(userBoxName);
    } catch (e) {
      // Handle schema mismatch gracefully
      try {
        await Hive.deleteBoxFromDisk(userBoxName);
      } catch (_) {
        // Ignore file not found exceptions during deletion
      }
      // Re-open fresh box
      await Hive.openBox<User>(userBoxName);
    }

    // Initialize SQLite (triggers table creation on first run)
    await SQLiteHelper.instance.database;
  }

  // ─────────────────────────────────────────────────────────────
  // USER (Hive — single object, no querying needed)
  // ─────────────────────────────────────────────────────────────
  static Box<User> get userBox => Hive.box<User>(userBoxName);

  static Future<void> saveUser(User user) async {
    await userBox.put('current_user', user);
  }

  static User? getUser() {
    return userBox.get('current_user');
  }

  // ─────────────────────────────────────────────────────────────
  // SETTINGS (Hive — key-value flags)
  // ─────────────────────────────────────────────────────────────
  static Box get settingsBox => Hive.box(settingsBoxName);

  static bool hasCompletedOnboarding() {
    return settingsBox.get('hasCompletedOnboarding', defaultValue: false);
  }

  static Future<void> setOnboardingCompleted() async {
    await settingsBox.put('hasCompletedOnboarding', true);
  }

  static bool isLoggedIn() {
    return settingsBox.get('isLoggedIn', defaultValue: false);
  }

  static Future<void> setLoggedIn(bool value) async {
    await settingsBox.put('isLoggedIn', value);
  }

  /// True when the user intentionally tapped "Logout".
  /// Distinguishes deliberate logout (needs full login) from
  /// app-close/background (needs PIN unlock).
  static bool isExplicitlyLoggedOut() {
    return settingsBox.get('isExplicitlyLoggedOut', defaultValue: false);
  }

  static Future<void> setExplicitlyLoggedOut(bool value) async {
    await settingsBox.put('isExplicitlyLoggedOut', value);
  }

  /// Whether the user has enabled the in-app PIN/biometric lock.
  static bool isPinLockEnabled() {
    return settingsBox.get('isPinLockEnabled', defaultValue: false);
  }

  static Future<void> setPinLockEnabled(bool value) async {
    await settingsBox.put('isPinLockEnabled', value);
  }

  /// Whether we have already shown the "Set up your PIN lock" prompt.
  static bool hasShownLockSetupPrompt() {
    return settingsBox.get('hasShownLockSetupPrompt', defaultValue: false);
  }

  static Future<void> setHasShownLockSetupPrompt(bool value) async {
    await settingsBox.put('hasShownLockSetupPrompt', value);
  }

  // ─────────────────────────────────────────────────────────────
  // NOTIFICATION PREFERENCES (Hive — single object)
  // ─────────────────────────────────────────────────────────────
  static Box<NotificationPreferences> get notificationPrefsBox =>
      Hive.box<NotificationPreferences>(notificationPrefsBoxName);

  static Future<void> saveNotificationPrefs(NotificationPreferences prefs) async {
    await notificationPrefsBox.put('current_prefs', prefs);
  }

  static NotificationPreferences getNotificationPrefs() {
    return notificationPrefsBox.get('current_prefs') ?? NotificationPreferences();
  }

  // ─────────────────────────────────────────────────────────────
  // TRANSACTIONS (SQLite)
  // ─────────────────────────────────────────────────────────────
  static Future<void> saveTransactions(List<BudgetTransaction> transactions) async {
    final db = SQLiteHelper.instance;
    final now = DateTime.now();
    for (final tx in transactions) {
      final map = tx.toMap();
      // Avoid duplicates using reference (tx.id) check
      final existing = await db.database.then((d) => d.query(
            'sms_transactions',
            where: 'reference = ?',
            whereArgs: [tx.id],
          ));
      if (existing.isEmpty) {
        map['createdAt'] = now.toIso8601String();
        await db.database.then((d) => d.insert('sms_transactions', map));
      }
    }
  }

  static Future<List<BudgetTransaction>> getAllTransactions() async {
    final rows = await SQLiteHelper.instance.getAllTransactions();
    return rows.map((model) => BudgetTransaction(
          id: model.reference ?? model.id?.toString() ?? '',
          dbId: model.id,
          amount: model.amount,
          type: (model.type.toLowerCase() == 'credit' || model.type.toLowerCase() == 'income') 
                  ? TransactionType.credit 
                  : TransactionType.debit,
          category: model.category,
          timestamp: model.createdAt,
          senderOrReceiver: model.merchant ?? model.sender ?? model.receiver ?? 'Unknown',
          rawMessage: model.rawSms,
        )).toList();
  }

  // ─────────────────────────────────────────────────────────────
  // BUDGETS (SQLite)
  // ─────────────────────────────────────────────────────────────
  static Future<void> saveBudget(Budget budget) async {
    await SQLiteHelper.instance.insertBudget(budget);
  }

  static Future<List<Budget>> getAllBudgetsAsync() async {
    return await SQLiteHelper.instance.getBudgets();
  }

  static Future<void> deleteBudget(String id) async {
    await SQLiteHelper.instance.deleteBudget(id);
  }

  // ─────────────────────────────────────────────────────────────
  // SAVINGS GOALS (SQLite)
  // ─────────────────────────────────────────────────────────────
  static Future<void> saveGoal(SavingsGoal goal) async {
    await SQLiteHelper.instance.insertGoal(goal);
  }

  static Future<void> updateGoal(SavingsGoal goal) async {
    await SQLiteHelper.instance.updateGoal(goal);
  }

  static Future<List<SavingsGoal>> getAllGoalsAsync() async {
    return await SQLiteHelper.instance.getGoals();
  }

  // ─────────────────────────────────────────────────────────────
  // BILLS (SQLite)
  // ─────────────────────────────────────────────────────────────
  static Future<void> saveBill(Bill bill) async {
    await SQLiteHelper.instance.insertBill(bill);
  }

  static Future<void> updateBill(Bill bill) async {
    await SQLiteHelper.instance.updateBill(bill);
  }

  static Future<List<Bill>> getAllBillsAsync() async {
    return await SQLiteHelper.instance.getBills();
  }

  static Future<void> deleteBill(String id) async {
    await SQLiteHelper.instance.deleteBill(id);
  }

  // ─────────────────────────────────────────────────────────────
  // WALLET (SQLite — single row)
  // ─────────────────────────────────────────────────────────────
  static Future<Wallet> getWalletAsync() async {
    return await SQLiteHelper.instance.getWallet();
  }

  static Future<void> saveWallet(Wallet wallet) async {
    await SQLiteHelper.instance.updateWallet(wallet);
  }
}
