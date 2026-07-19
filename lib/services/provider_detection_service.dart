class ProviderDetectionService {
  static const List<String> financialKeywords = [
    'momo',
    'mtn',
    'telecel',
    'vodafone',
    'airtel',
    'tigo',
    'bank',
    'pay',
    'cash',
    'mobilemoney',
    'ecobank',
    'fidelity',
    'stanbic',
    'gcb',
    'absa',
    'uba',
  ];

  static bool isFinancialProvider(String senderId) {
    final sender = senderId.toLowerCase().replaceAll(' ', '');
    return financialKeywords.any((kw) => sender.contains(kw));
  }

  static String detectProvider(String senderId) {
    final sender = senderId.toLowerCase().replaceAll(' ', '');
    
    if (sender.contains('mtn') || sender.contains('momo') || sender.contains('mobilemoney')) {
      return 'MTN';
    } else if (sender.contains('telecel') || sender.contains('vodafone')) {
      return 'Telecel';
    } else if (sender.contains('airtel') || sender.contains('tigo')) {
      return 'AirtelTigo';
    } else if (sender.contains('ecobank')) {
      return 'Ecobank';
    } else if (sender.contains('fidelity')) {
      return 'Fidelity';
    } else if (sender.contains('stanbic')) {
      return 'Stanbic';
    } else if (sender.contains('gcb')) {
      return 'GCB';
    } else if (sender.contains('absa')) {
      return 'Absa';
    } else if (sender.contains('uba')) {
      return 'UBA';
    }
    
    return 'Unknown Provider';
  }
}
