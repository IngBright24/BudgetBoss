import 'regex_patterns.dart';
import '../models/sms_transaction_model.dart';
import '../../services/provider_detection_service.dart';

/// All categories supported by the app.
const List<String> kAllCategories = [
  'Food',
  'Groceries',
  'Transport',
  'Bills',
  'Data/Airtime',
  'Healthcare',
  'Shopping',
  'Entertainment',
  'Education',
  'Transfers',
  'Savings',
  'Cash Withdrawal',
  'Income',
  'Uncategorized',
];

class SmsParser {
  static SmsTransactionModel? parse(String rawSms, String senderNumber, DateTime timestamp, {Map<String, String>? customRules}) {
    String? type;
    double? amount;
    String currency = 'GHS';
    String counterparty = 'Unknown';
    String? reference;
    String category = 'Uncategorized';
    String provider = ProviderDetectionService.detectProvider(senderNumber);

    try {
      // Clean up SMS body
      final body = rawSms.replaceAll('\n', ' ');

      bool matched = false;

      // Extract reference independently since it can appear anywhere
      final refMatch = RegExp(r'(?:Financial Transaction Id|External Transaction Id|Transaction ID|Transaction Id)\s*[:\-]?\s*([0-9A-Z]{6,})|^\s*(\d{10,})\s+Confirmed', caseSensitive: false).firstMatch(body);
      reference = refMatch?.group(1) ?? refMatch?.group(2);

      // ================== MTN MoMo ==================
      if (!matched) {
        final paymentReal1 = RegexPatterns.mtnPaymentReal1.firstMatch(body);
        if (paymentReal1 != null) {
          type = 'Expense';
          amount = _parseDouble(paymentReal1.group(2)!);
          counterparty = paymentReal1.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final incomeReal1 = RegexPatterns.mtnIncomeReal1.firstMatch(body);
        if (incomeReal1 != null) {
          type = 'Income';
          amount = _parseDouble(incomeReal1.group(2)!);
          counterparty = incomeReal1.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final cashOutReal1 = RegexPatterns.mtnCashOutReal1.firstMatch(body);
        if (cashOutReal1 != null) {
          type = 'Withdrawal';
          amount = _parseDouble(cashOutReal1.group(2)!);
          counterparty = cashOutReal1.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final paymentReal2 = RegexPatterns.mtnPaymentReal2.firstMatch(body);
        if (paymentReal2 != null) {
          type = 'Expense';
          amount = _parseDouble(paymentReal2.group(2)!);
          counterparty = paymentReal2.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final incomeReal2 = RegexPatterns.mtnIncomeReal2.firstMatch(body);
        if (incomeReal2 != null) {
          type = 'Income';
          amount = _parseDouble(incomeReal2.group(2)!);
          counterparty = incomeReal2.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final paymentReal3 = RegexPatterns.mtnPaymentReal3.firstMatch(body);
        if (paymentReal3 != null) {
          type = 'Expense';
          amount = _parseDouble(paymentReal3.group(2)!);
          counterparty = paymentReal3.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final income = RegexPatterns.mtnIncome.firstMatch(body);
        if (income != null) {
          type = 'Income';
          amount = _parseDouble(income.group(2)!);
          counterparty = income.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final payment = RegexPatterns.mtnPayment.firstMatch(body);
        if (payment != null) {
          type = 'Expense';
          amount = _parseDouble(payment.group(2)!);
          counterparty = payment.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final cashOut = RegexPatterns.mtnCashOut.firstMatch(body);
        if (cashOut != null) {
          type = 'Withdrawal';
          amount = _parseDouble(cashOut.group(2)!);
          counterparty = cashOut.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final transfer = RegexPatterns.mtnTransfer.firstMatch(body);
        if (transfer != null) {
          type = 'Transfer';
          amount = _parseDouble(transfer.group(2)!);
          counterparty = transfer.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final transferNew = RegexPatterns.mtnTransferNew.firstMatch(body);
        if (transferNew != null) {
          type = 'Expense';
          amount = _parseDouble(transferNew.group(2)!);
          counterparty = transferNew.group(3)!.trim();
          matched = true;
        }
      }

      // ================== Vodafone / Telecel Cash ==================
      if (!matched) {
        final payment = RegexPatterns.vodaPayment.firstMatch(body);
        if (payment != null) {
          type = 'Expense';
          amount = _parseDouble(payment.group(2)!);
          counterparty = payment.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final paymentNew = RegexPatterns.vodaPaymentNew.firstMatch(body);
        if (paymentNew != null) {
          type = 'Expense';
          amount = _parseDouble(paymentNew.group(2)!);
          counterparty = paymentNew.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final cashOut = RegexPatterns.vodaCashOut.firstMatch(body);
        if (cashOut != null) {
          type = 'Withdrawal';
          amount = _parseDouble(cashOut.group(2)!);
          counterparty = cashOut.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final transfer = RegexPatterns.vodaTransfer.firstMatch(body);
        if (transfer != null) {
          type = 'Transfer';
          amount = _parseDouble(transfer.group(2)!);
          counterparty = transfer.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final income = RegexPatterns.vodaIncome.firstMatch(body);
        if (income != null) {
          type = 'Income';
          amount = _parseDouble(income.group(2)!);
          counterparty = income.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final incomeNew = RegexPatterns.vodaIncomeNew.firstMatch(body);
        if (incomeNew != null) {
          type = 'Income';
          amount = _parseDouble(incomeNew.group(2)!);
          counterparty = incomeNew.group(3)!.trim();
          matched = true;
        }
      }

      // ================== AirtelTigo Money ==================
      if (!matched) {
        final payment = RegexPatterns.airtelPayment.firstMatch(body);
        if (payment != null) {
          type = 'Expense';
          amount = _parseDouble(payment.group(2)!);
          counterparty = payment.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final cashOut = RegexPatterns.airtelCashOut.firstMatch(body);
        if (cashOut != null) {
          type = 'Withdrawal';
          amount = _parseDouble(cashOut.group(2)!);
          counterparty = cashOut.group(3)!.trim();
          matched = true;
        }
      }
      if (!matched) {
        final transfer = RegexPatterns.airtelTransfer.firstMatch(body);
        if (transfer != null) {
          type = 'Transfer';
          amount = _parseDouble(transfer.group(2)!);
          counterparty = transfer.group(3)!.trim();
          matched = true;
        }
      }

      // ================== Generic Bank Fallback ==================
      if (!matched) {
        final genericDebitMatch = RegexPatterns.genericDebit.firstMatch(body);
        if (genericDebitMatch != null) {
          type = 'Expense';
          amount = _parseDouble(genericDebitMatch.group(2)!);
          counterparty = provider;
          matched = true;
        }
      }
      if (!matched) {
        final genericCreditMatch = RegexPatterns.genericCredit.firstMatch(body);
        if (genericCreditMatch != null) {
          type = 'Income';
          amount = _parseDouble(genericCreditMatch.group(2)!);
          counterparty = provider;
          matched = true;
        }
      }

      if (!matched || type == null || amount == null) {
        // Did not match any regex, fallback to Needs Review
        return _buildNeedsReviewModel(rawSms, timestamp, provider);
      }

      // Determine Category
      final normalizedCounterparty = counterparty.trim().toUpperCase();
      
      if (type == 'Withdrawal' || normalizedCounterparty.startsWith('AGENT')) {
         category = 'Cash Withdrawal';
      } else if (type == 'Income') {
         category = 'Income'; 
      }

      // 1. Check User-Defined Custom Rules (Auto-Learning)
      if (customRules != null && customRules.containsKey(normalizedCounterparty)) {
        category = customRules[normalizedCounterparty]!;
      } 
      // 2. Fallback to Hardcoded Rules
      else {
        // Only infer if we haven't already determined a strong category like Income or Cash Withdrawal
        if (category == 'Uncategorized') {
          String inferred = _categorize(counterparty);
          if (inferred != 'Other') {
            category = inferred;
          }
        }
      }

      return SmsTransactionModel(
        amount: amount,
        currency: currency,
        type: type,
        merchant: (type == 'Expense' || type == 'Withdrawal') ? counterparty : null,
        sender: type == 'Income' ? counterparty : null,
        receiver: type == 'Transfer' ? counterparty : null,
        date: _formatDate(timestamp),
        time: _formatTime(timestamp),
        reference: reference,
        category: category,
        provider: provider,
        rawSms: rawSms,
        isParsed: true, // We successfully parsed it
        createdAt: timestamp,
      );

    } catch (e) {
      // If parsing crashes, gracefully fallback
      return _buildNeedsReviewModel(rawSms, timestamp, provider);
    }
  }

  static SmsTransactionModel _buildNeedsReviewModel(String rawSms, DateTime timestamp, String provider) {
    return SmsTransactionModel(
      amount: 0.0,
      currency: 'GHS',
      type: 'Needs Review',
      date: _formatDate(timestamp),
      time: _formatTime(timestamp),
      category: 'Needs Review',
      provider: provider,
      rawSms: rawSms,
      isParsed: true, 
      createdAt: timestamp,
    );
  }

  static double _parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Comprehensive Ghanaian-context keyword categorization.
  /// Keywords are matched against the lowercased merchant/sender name.
  static String _categorize(String entity) {
    final e = entity.toLowerCase();

    // ── Income / Salary ─────────────────────────────────────────
    if (_any(e, ['salary', 'payroll', 'wages', 'stipend', 'commission',
        'dividend', 'bonus', 'allowance', 'pension', 'gratuity',
        'freelance', 'consultancy fee', 'contract pay', 'ghana revenue',
        'gra refund', 'ssnit'])) {
      return 'Income';
    }

    // ── Food & Dining ────────────────────────────────────────────
    if (_any(e, ['kfc', 'chicken republic', 'papaye', 'pizza', 'mr biggs',
        'tasty', 'food court', 'restaurant', 'eatery', 'kitchen',
        'chop bar', 'canteen', 'cafe', 'bakery', 'pastry', 'donut',
        'waakye', 'banku', 'fufu', 'jollof', 'shawarma', 'suya',
        'burger', 'grill', 'bbq', 'barbeque', 'sushi', 'noodles',
        'hotdog', 'sandwich', 'snack', 'ice cream', 'yoghurt',
        'dominos', 'pizza hut', 'frankie', 'buka', 'afrikiko',
        'kumasi chophouse', 'gold coast', 'chicken inn', 'tantalizers',
        'steers', 'nandos', 'food', 'drinks', 'bar &'])) {
      return 'Food';
    }

    // ── Groceries & Supermarkets ─────────────────────────────────
    if (_any(e, ['shoprite', 'palace', 'melcom', 'max mart', 'maxmart',
        'market', 'supermarket', 'grocery', 'provisions', 'provision store',
        'wholesale', 'agbogbloshie', 'kejetia', 'makola', 'kasoa market',
        'fruits', 'vegetables', 'produce', 'store', 'minimart',
        'convenience', 'spar', 'koala', 'marina mall', 'accra mall',
        'junction mall', 'west hills mall', 'game stores'])) {
      return 'Groceries';
    }

    // ── Transport ────────────────────────────────────────────────
    if (_any(e, ['uber', 'bolt', 'yango', 'lyft', 'taxify', 'okada',
        'trotro', 'metro mass', 'stc', 'vip bus', 'oyster transport',
        'vanef', 'airport', 'fare', 'transport', 'fuel', 'petrol',
        'diesel', 'total', 'shell', 'goil', 'star oil', 'benab',
        'puma', 'tex', 'tank', 'zeno', 'calix', 'driver',
        'garage', 'auto', 'vehicle', 'car wash', 'parking',
        'toll', 'tollbooth', 'metro'])) {
      return 'Transport';
    }

    // ── Bills & Utilities ────────────────────────────────────────
    if (_any(e, ['ecg', 'electricity', 'ghana water', 'gwcl', 'water company',
        'dstv', 'gotv', 'startimes', 'netflix', 'showmax', 'youtube premium',
        'internet', 'broadband', 'wifi', 'fiber', 'busy internet',
        'surfline', 'vodafone broadband', 'mtn broadband',
        'rent', 'landlord', 'landlady', 'estate', 'property',
        'ghana gas', 'gas bill', 'lpg', 'cooking gas',
        'insurance', 'premium', 'star life', 'enterprise',
        'sic insurance', 'nhis', 'national health'])) {
      return 'Bills';
    }

    // ── Data & Airtime ───────────────────────────────────────────
    if (_any(e, ['mtn', 'telecel', 'airtel', 'airteltigo', 'glo',
        'airtime', 'bundle', 'data bundle', 'credit', 'recharge',
        'top up', 'topup', 'sms bundle', 'voice bundle',
        'weekly bundle', 'monthly bundle', 'daily bundle'])) {
      return 'Data/Airtime';
    }

    // ── Healthcare ───────────────────────────────────────────────
    if (_any(e, ['hospital', 'clinic', 'pharmacy', 'drugstore', 'chemist',
        'medical', 'health center', 'health centre', 'polyclinic',
        'doctor', 'dentist', 'optician', 'lab', 'laboratory',
        'korle bu', 'komfo anokye', '37 military', 'ridge hospital',
        'lap hospital', 'mediplan', 'health', 'physiotherapy',
        'nyaho', 'trust hospital', 'international hospital'])) {
      return 'Healthcare';
    }

    // ── Shopping & Retail ────────────────────────────────────────
    if (_any(e, ['jumia', 'tonaton', 'jiji', 'amazon', 'aliexpress',
        'ebay', 'clothing', 'boutique', 'fashion', 'apparel', 'shoes',
        'footwear', 'accessories', 'jewellery', 'jewelry', 'watch',
        'electronics', 'appliances', 'furniture', 'hardware',
        'building materials', 'phone', 'laptop', 'gadget',
        'computer', 'samsung', 'apple store', 'istore', 'game',
        'toys', 'baby shop', 'kids'])) {
      return 'Shopping';
    }

    // ── Entertainment ────────────────────────────────────────────
    if (_any(e, ['cinema', 'silverbird', 'movie', 'film', 'theatre',
        'concert', 'event', 'ticket', 'club', 'lounge', 'bar',
        'pub', 'nightclub', 'beach', 'resort', 'hotel', 'spa',
        'massage', 'leisure', 'fun', 'sport', 'gym', 'fitness',
        'swimming', 'pool', 'bowling', 'game center', 'playstation',
        'steam', 'spotify', 'apple music', 'deezer'])) {
      return 'Entertainment';
    }

    // ── Education ────────────────────────────────────────────────
    if (_any(e, ['school', 'college', 'university', 'tuition', 'fees',
        'ug fees', 'knust', 'ghana tech', 'ucc', 'legon',
        'textbook', 'books', 'stationery', 'library', 'exam',
        'waec', 'novdec', 'registration fee', 'course fee',
        'institute', 'training', 'workshop', 'seminar'])) {
      return 'Education';
    }

    // ── Savings / Goals ──────────────────────────────────────────
    if (_any(e, ['savings', 'susu', 'nsia', 'databank', 'gold fund',
        'pension fund', 'investment', 'unit trust', 'fixed deposit',
        'cal bank savings', 'ecobank savings'])) {
      return 'Savings';
    }

    // ── Transfers (person-to-person) ─────────────────────────────
    if (_any(e, ['transfer', 'send money', 'mobile money transfer',
        'momo transfer', 'p2p', 'personal'])) {
      return 'Transfers';
    }

    return 'Other';
  }

  /// Returns true if [text] contains any of the [keywords].
  static bool _any(String text, List<String> keywords) {
    return keywords.any((kw) => text.contains(kw));
  }
}
