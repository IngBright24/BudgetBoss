class Wallet {
  double balance;
  double totalDeposits;
  double totalExpenses;

  Wallet({
    this.balance = 0.0,
    this.totalDeposits = 0.0,
    this.totalExpenses = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'balance': balance,
      'totalDeposits': totalDeposits,
      'totalExpenses': totalExpenses,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      balance: map['balance'] as double,
      totalDeposits: map['totalDeposits'] as double,
      totalExpenses: map['totalExpenses'] as double,
    );
  }
}
