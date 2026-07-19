class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final bool isCompleted;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] as String,
      title: map['title'] as String,
      targetAmount: map['targetAmount'] as double,
      currentAmount: map['currentAmount'] as double,
      deadline: DateTime.parse(map['deadline'] as String),
      isCompleted: (map['isCompleted'] as int) == 1,
    );
  }

  SavingsGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
