import 'package:uuid/uuid.dart';

class Budget {
  final String id;
  final String category;
  final double limitAmount;
  final String period; // 'weekly' or 'monthly'
  final bool isGlobal;

  Budget({
    String? id,
    required this.category,
    required this.limitAmount,
    required this.period,
    this.isGlobal = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'limitAmount': limitAmount,
      'period': period,
      'isGlobal': isGlobal ? 1 : 0,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      category: map['category'] as String,
      limitAmount: map['limitAmount'] as double,
      period: map['period'] as String,
      isGlobal: (map['isGlobal'] as int) == 1,
    );
  }

  Budget copyWith({
    String? id,
    String? category,
    double? limitAmount,
    String? period,
    bool? isGlobal,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      period: period ?? this.period,
      isGlobal: isGlobal ?? this.isGlobal,
    );
  }
}
