import '../../domain/entities/sms_transaction.dart';

class SmsTransactionModel extends SmsTransaction {
  SmsTransactionModel({
    super.id,
    required super.amount,
    required super.currency,
    required super.type,
    super.merchant,
    super.sender,
    super.receiver,
    required super.date,
    required super.time,
    super.reference,
    super.balance,
    required super.category,
    required super.provider,
    required super.rawSms,
    required super.isParsed,
    required super.createdAt,
  });

  factory SmsTransactionModel.fromMap(Map<String, dynamic> map) {
    return SmsTransactionModel(
      id: map['id'],
      amount: map['amount'],
      currency: map['currency'],
      type: map['type'],
      merchant: map['merchant'],
      sender: map['sender'],
      receiver: map['receiver'],
      date: map['date'],
      time: map['time'],
      reference: map['reference'],
      balance: map['balance'],
      category: map['category'],
      provider: map['provider'],
      rawSms: map['raw_sms'],
      isParsed: map['isParsed'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'type': type,
      'merchant': merchant,
      'sender': sender,
      'receiver': receiver,
      'date': date,
      'time': time,
      'reference': reference,
      'balance': balance,
      'category': category,
      'provider': provider,
      'raw_sms': rawSms,
      'isParsed': isParsed ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SmsTransactionModel.fromEntity(SmsTransaction entity) {
    return SmsTransactionModel(
      id: entity.id,
      amount: entity.amount,
      currency: entity.currency,
      type: entity.type,
      merchant: entity.merchant,
      sender: entity.sender,
      receiver: entity.receiver,
      date: entity.date,
      time: entity.time,
      reference: entity.reference,
      balance: entity.balance,
      category: entity.category,
      provider: entity.provider,
      rawSms: entity.rawSms,
      isParsed: entity.isParsed,
      createdAt: entity.createdAt,
    );
  }
}
