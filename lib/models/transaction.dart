enum TransactionType {
  credit,
  debit,
}

class BudgetTransaction {
  final String id;
  final int? dbId;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime timestamp;
  final String senderOrReceiver;
  final String rawMessage;

  BudgetTransaction({
    required this.id,
    this.dbId,
    required this.amount,
    required this.type,
    required this.category,
    required this.timestamp,
    required this.senderOrReceiver,
    required this.rawMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': 'GHS',
      'type': type.name,
      'merchant': null,
      'sender': type == TransactionType.credit ? senderOrReceiver : null,
      'receiver': type == TransactionType.debit ? senderOrReceiver : null,
      'date': '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}',
      'time': '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
      'reference': id,
      'balance': null,
      'category': category,
      'provider': 'MANUAL',
      'raw_sms': rawMessage,
      'isParsed': 1,
      'createdAt': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'BudgetTransaction(id: $id, amount: $amount, type: $type, category: $category, timestamp: $timestamp, to/from: $senderOrReceiver)';
  }
}
