class Bill {
  final String id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final String category;
  final String? notes;
  bool isPaid;
  final bool isRecurring;
  DateTime? lastPaidDate;

  Bill({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.notes,
    this.isPaid = false,
    this.isRecurring = false,
    this.lastPaidDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'category': category,
      'notes': notes,
      'isPaid': isPaid ? 1 : 0,
      'isRecurring': isRecurring ? 1 : 0,
      'lastPaidDate': lastPaidDate?.toIso8601String(),
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: map['amount'] as double,
      dueDate: DateTime.parse(map['dueDate'] as String),
      category: map['category'] as String,
      notes: map['notes'] as String?,
      isPaid: (map['isPaid'] as int) == 1,
      isRecurring: (map['isRecurring'] as int) == 1,
      lastPaidDate: map['lastPaidDate'] != null
          ? DateTime.parse(map['lastPaidDate'] as String)
          : null,
    );
  }

  Bill copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? dueDate,
    String? category,
    String? notes,
    bool? isPaid,
    bool? isRecurring,
    DateTime? lastPaidDate,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isPaid: isPaid ?? this.isPaid,
      isRecurring: isRecurring ?? this.isRecurring,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
    );
  }
}
