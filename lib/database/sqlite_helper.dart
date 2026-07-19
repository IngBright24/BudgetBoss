import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../data/models/sms_transaction_model.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/bill.dart';
import '../models/wallet.dart';

class SQLiteHelper {
  static final SQLiteHelper instance = SQLiteHelper._init();
  static Database? _database;

  SQLiteHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budget_boss.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // --- SMS / Manual Transactions ---
    await db.execute('''
CREATE TABLE sms_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL,
  currency TEXT NOT NULL,
  type TEXT NOT NULL,
  merchant TEXT,
  sender TEXT,
  receiver TEXT,
  date TEXT NOT NULL,
  time TEXT NOT NULL,
  reference TEXT,
  balance REAL,
  category TEXT NOT NULL,
  provider TEXT NOT NULL,
  raw_sms TEXT NOT NULL,
  isParsed INTEGER NOT NULL,
  createdAt TEXT NOT NULL
)
''');

    // --- Budgets ---
    await db.execute('''
CREATE TABLE budgets (
  id TEXT PRIMARY KEY,
  category TEXT NOT NULL,
  limitAmount REAL NOT NULL,
  period TEXT NOT NULL,
  isGlobal INTEGER NOT NULL DEFAULT 0
)
''');

    // --- Savings Goals ---
    await db.execute('''
CREATE TABLE savings_goals (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  targetAmount REAL NOT NULL,
  currentAmount REAL NOT NULL DEFAULT 0,
  deadline TEXT NOT NULL,
  isCompleted INTEGER NOT NULL DEFAULT 0
)
''');

    // --- Bills ---
    await db.execute('''
CREATE TABLE bills (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  amount REAL NOT NULL,
  dueDate TEXT NOT NULL,
  category TEXT NOT NULL,
  notes TEXT,
  isPaid INTEGER NOT NULL DEFAULT 0,
  isRecurring INTEGER NOT NULL DEFAULT 0,
  lastPaidDate TEXT
)
''');

    // --- Wallet (single row) ---
    await db.execute('''
CREATE TABLE wallet (
  id INTEGER PRIMARY KEY DEFAULT 1,
  balance REAL NOT NULL DEFAULT 0,
  totalDeposits REAL NOT NULL DEFAULT 0,
  totalExpenses REAL NOT NULL DEFAULT 0
)
''');

    // --- Category Rules ---
    await db.execute('''
CREATE TABLE category_rules (
  counterparty TEXT PRIMARY KEY,
  category TEXT NOT NULL
)
''');

    // Insert the default wallet row
    await db.insert('wallet', {'id': 1, 'balance': 0.0, 'totalDeposits': 0.0, 'totalExpenses': 0.0});
  }

  // ─────────────────────────────────────────────────────────────
  // SMS TRANSACTIONS
  // ─────────────────────────────────────────────────────────────

  Future<int> insertTransaction(SmsTransactionModel transaction) async {
    try {
      final db = await instance.database;
      return await db.insert('sms_transactions', transaction.toMap());
    } catch (e) {
      debugPrint('SQLite Error (insertTransaction): $e');
      return -1;
    }
  }

  Future<bool> isDuplicate(SmsTransactionModel transaction) async {
    try {
      final db = await instance.database;

      // Check 1: Reference Match (If parsed and has reference)
      if (transaction.reference != null && transaction.reference!.isNotEmpty) {
        final res = await db.query(
          'sms_transactions',
          where: 'reference = ?',
          whereArgs: [transaction.reference],
        );
        if (res.isNotEmpty) return true;
      }

      // Check 2: Exact SMS Match (Bulletproof fallback for unparsed or missing reference)
      final res = await db.query(
        'sms_transactions',
        where: 'raw_sms = ?',
        whereArgs: [transaction.rawSms],
      );
      if (res.isNotEmpty) return true;

      return false;
    } catch (e) {
      debugPrint('SQLite Error (isDuplicate): $e');
      return false; // Safely return false so we don't drop everything
    }
  }

  Future<void> deleteNeedsReviewTransactions() async {
    final db = await instance.database;
    await db.delete('sms_transactions', where: 'type = ?', whereArgs: ['Needs Review']);
    debugPrint('Wiped old Needs Review transactions.');
  }

  Future<List<SmsTransactionModel>> getAllTransactions() async {
    try {
      final db = await instance.database;
      
      // Wipe the ENTIRE sms_transactions table once to clear all legacy demo data
      // This ensures the user starts with a completely fresh slate without hardcoded figures.
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('has_wiped_legacy_data_v2') != true) {
        await db.delete('sms_transactions');
        await prefs.setBool('has_wiped_legacy_data_v2', true);
        debugPrint('Legacy demo data wiped completely.');
      }

      // Fix any bugged transactions (like 1970) by updating them to today's date so they aren't lost
      final nowStr = DateTime.now().toIso8601String();
      await db.rawUpdate('''
        UPDATE sms_transactions 
        SET createdAt = ?, date = ? 
        WHERE createdAt < '2020'
      ''', [nowStr, nowStr.split('T')[0]]);

      final result = await db.query('sms_transactions', orderBy: 'createdAt DESC');
      
      print('=== DB DUMP ===');
      for (var r in result) {
        print('ID: ${r['id']} | type: ${r['type']} | amt: ${r['amount']} | createdAt: ${r['createdAt']} | date: ${r['date']} | sms: ${r['raw_sms']}');
      }
      print('===============');

      return result.map((json) => SmsTransactionModel.fromMap(json)).toList();
    } catch (e) {
      debugPrint('SQLite Error (getAllTransactions): $e');
      return [];
    }
  }

  Future<void> updateTransactionCategory(int id, String category) async {
    final db = await instance.database;
    await db.update(
      'sms_transactions',
      {'category': category},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BUDGETS
  // ─────────────────────────────────────────────────────────────

  Future<void> insertBudget(Budget budget) async {
    final db = await instance.database;
    await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Budget>> getBudgets() async {
    final db = await instance.database;
    final result = await db.query('budgets');
    return result.map((m) => Budget.fromMap(m)).toList();
  }

  Future<void> deleteBudget(String id) async {
    final db = await instance.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────────────────────────────────────────────────
  // SAVINGS GOALS
  // ─────────────────────────────────────────────────────────────

  Future<void> insertGoal(SavingsGoal goal) async {
    final db = await instance.database;
    await db.insert(
      'savings_goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    final db = await instance.database;
    await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<List<SavingsGoal>> getGoals() async {
    final db = await instance.database;
    final result = await db.query('savings_goals');
    return result.map((m) => SavingsGoal.fromMap(m)).toList();
  }

  Future<void> deleteGoal(String id) async {
    final db = await instance.database;
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────────────────────────────────────────────────
  // BILLS
  // ─────────────────────────────────────────────────────────────

  Future<void> insertBill(Bill bill) async {
    final db = await instance.database;
    await db.insert(
      'bills',
      bill.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateBill(Bill bill) async {
    final db = await instance.database;
    await db.update(
      'bills',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<List<Bill>> getBills() async {
    final db = await instance.database;
    final result = await db.query('bills');
    return result.map((m) => Bill.fromMap(m)).toList();
  }

  Future<void> deleteBill(String id) async {
    final db = await instance.database;
    await db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────────────────────────────────────────────────
  // WALLET (single-row record)
  // ─────────────────────────────────────────────────────────────

  Future<Wallet> getWallet() async {
    final db = await instance.database;
    final result = await db.query('wallet', where: 'id = ?', whereArgs: [1]);
    if (result.isEmpty) return Wallet();
    return Wallet.fromMap(result.first);
  }

  Future<void> updateWallet(Wallet wallet) async {
    final db = await instance.database;
    await db.update(
      'wallet',
      wallet.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
