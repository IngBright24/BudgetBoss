class SmsTransaction {
  final int? id;
  final double amount;
  final String currency;
  final String type; // Income, Expense, Transfer, Withdrawal, Deposit
  final String? merchant;
  final String? sender;
  final String? receiver;
  final String date; // YYYY-MM-DD
  final String time; // HH:MM
  final String? reference;
  final double? balance;
  final String category;
  final String provider; // e.g., MTN MoMo, Telecel
  final String rawSms;
  final bool isParsed;
  final DateTime createdAt;

  SmsTransaction({
    this.id,
    required this.amount,
    required this.currency,
    required this.type,
    this.merchant,
    this.sender,
    this.receiver,
    required this.date,
    required this.time,
    this.reference,
    this.balance,
    required this.category,
    required this.provider,
    required this.rawSms,
    required this.isParsed,
    required this.createdAt,
  });
}
