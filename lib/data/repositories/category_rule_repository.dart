import '../../database/sqlite_helper.dart';
import 'package:sqflite/sqflite.dart';

class CategoryRuleRepository {
  final SQLiteHelper _dbHelper = SQLiteHelper.instance;

  Future<void> saveRule(String counterparty, String category) async {
    final db = await _dbHelper.database;
    final normalizedKey = _normalize(counterparty);
    if (normalizedKey.isEmpty) return;

    await db.insert(
      'category_rules',
      {
        'counterparty': normalizedKey,
        'category': category,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getRule(String counterparty) async {
    final db = await _dbHelper.database;
    final normalizedKey = _normalize(counterparty);
    
    final result = await db.query(
      'category_rules',
      where: 'counterparty = ?',
      whereArgs: [normalizedKey],
    );

    if (result.isNotEmpty) {
      return result.first['category'] as String?;
    }
    return null;
  }

  Future<Map<String, String>> getAllRules() async {
    final db = await _dbHelper.database;
    final result = await db.query('category_rules');
    
    final Map<String, String> rules = {};
    for (var row in result) {
      rules[row['counterparty'] as String] = row['category'] as String;
    }
    return rules;
  }

  String _normalize(String input) {
    return input.trim().toUpperCase();
  }
}
