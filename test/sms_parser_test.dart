import 'package:flutter_test/flutter_test.dart';
import 'package:budget_boss/data/parser/sms_parser.dart';

void main() {
  group('SmsParser Tests (12 Formats)', () {
    final timestamp = DateTime.now();

    // ==========================================
    // Real MTN MoMo Formats (New)
    // ==========================================
    test('MTN MoMo Real - Format 1 (General payment DEBIT)', () {
      const body = "Payment made for GHS 0.50 to GLADYS SEGKULU Current Balance: GHS 168.20 . Available Balance: GHS 168.20. Reference: Test. Transaction ID: 85600795564. Fee charged: GHS0.00 Tax charged: 0. Download the MoMo App for a Faster & Easier Experience. Click here: [link]";
      final tx = SmsParser.parse(body, 'MobileMoney', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 0.50);
      expect(tx.merchant, "GLADYS SEGKULU");
      expect(tx.reference, '85600795564');
      expect(tx.type, 'Expense');
    });

    test('MTN MoMo Real - Format 2 (Payment received CREDIT)', () {
      const body = "Payment received for GHS 1520.00 from GABRIEL TWUMASI-ANKRAH  Current Balance: GHS 1637.84 . Available Balance: GHS 1637.84. Reference: 0000. Transaction ID: 85508667779. TRANSACTION FEE: 0.00";
      final tx = SmsParser.parse(body, 'MobileMoney', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 1520.00);
      expect(tx.sender, 'GABRIEL TWUMASI-ANKRAH');
      expect(tx.reference, '85508667779');
      expect(tx.type, 'Income');
    });

    test('MTN MoMo Real - Format 3 (Cash Out at agent DEBIT)', () {
      const body = "Cash Out made for GHS1450.00 to ALUBAS COMPANY LTD. Current Balance: GHS173.34 Financial Transaction Id: 85557267370. Cash-out fee is charged automatically from your MTN MoMo wallet. Please do not pay any fees to the Agent. Thank you for using MTN MobileMoney. Fee charged: GHS14.50.";
      final tx = SmsParser.parse(body, 'MobileMoney', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 1450.00);
      expect(tx.merchant, 'ALUBAS COMPANY LTD');
      expect(tx.reference, '85557267370');
      expect(tx.type, 'Withdrawal');
    });

    test('MTN MoMo Real - Format 4 (Short payment variant DEBIT)', () {
      const body = "Payment for GHS3.00 to MTN BUNDLE .Current Balance: GHS 88.34. Transaction Id: 85269363548. Fee charged: GHS0.00,Tax Charged 0.";
      final tx = SmsParser.parse(body, 'MobileMoney', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 3.00);
      expect(tx.merchant, 'MTN BUNDLE');
      expect(tx.reference, '85269363548');
      expect(tx.type, 'Expense');
    });

    test('MTN MoMo Real - Format 5 (Cash In / Deposit CREDIT)', () {
      const body = "Cash In received for GHS 1515.00 from DAVISANTWI VENTURES . Current Balance GHS 1603.34 Available Balance GHS 1603.34. Transaction ID: 85366037397. Fee charged: GHS 0. Cash in (Deposit) is a free transaction on MTN Mobile Money. Please do not pay any fees for it.";
      final tx = SmsParser.parse(body, 'MobileMoney', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 1515.00);
      expect(tx.sender, 'DAVISANTWI VENTURES');
      expect(tx.reference, '85366037397');
      expect(tx.type, 'Income');
    });

    test('MTN MoMo Real - Format 6 (Airtime/data/bill payment confirmation DEBIT)', () {
      const body = "Your payment of GHS 11.00 to TELECEL PUSH has been completed at 2026-07-12 09:46:35. Your new balance: GHS 111.34. Fee was GHS 0.38 Tax was GHS -. Reference: BRIGHT TWUMASI-ANKRAH,233504806489,Data. Financial Transaction Id: 85223314605. External Transaction Id: 85223314605.";
      final tx = SmsParser.parse(body, 'MobileMoney', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 11.00);
      expect(tx.merchant, 'TELECEL PUSH');
      expect(tx.reference, '85223314605'); // Verifying we skipped "BRIGHT..."
      expect(tx.type, 'Expense');
    });

    // ==========================================
    // MTN MoMo Patterns (Legacy)
    // ==========================================
    test('MTN MoMo - Payment', () {
      const body = "You have paid GHS 45.00 to KOFI'S PROVISION SHOP. Your balance is GHS 320.50. BudgetTransaction ID: 8892034571. Fee charged: GHS 0.00.";
      final tx = SmsParser.parse(body, 'MobileMoney', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 45.00);
      expect(tx.merchant, "KOFI'S PROVISION SHOP");
      expect(tx.reference, '8892034571');
      expect(tx.type, 'Expense');
      expect(tx.provider, 'MTN'); // ProviderDetectionService returns 'MTN'
    });

    test('MTN MoMo - Cash Out', () {
      const body = "You have withdrawn GHS 200.00 from Agent KWABENA STORES (0244123456). Your balance is GHS 120.50. BudgetTransaction ID: 8892034812. Fee charged: GHS 2.00.";
      final tx = SmsParser.parse(body, 'MobileMoney', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 200.00);
      expect(tx.merchant, 'KWABENA STORES (0244123456)'); // Legacy regex explicitly skips "Agent"
      expect(tx.reference, '8892034812');
      expect(tx.type, 'Withdrawal');
      expect(tx.category, 'Cash Withdrawal');
    });

    test('MTN MoMo - Transfer', () {
      const body = "You have sent GHS 100.00 to ABENA OSEI (0201234567). Your balance is GHS 220.50. BudgetTransaction ID: 8892035102. Fee charged: GHS 1.00.";
      final tx = SmsParser.parse(body, 'MobileMoney', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 100.00);
      expect(tx.receiver, 'ABENA OSEI (0201234567)');
      expect(tx.reference, '8892035102');
      expect(tx.type, 'Transfer');
    });

    test('MTN MoMo - Income', () {
      const body = "You have received GHS 500.00 from KWAME ADJEI (0551234567). Your balance is GHS 720.50. BudgetTransaction ID: 8892035390.";
      final tx = SmsParser.parse(body, 'MobileMoney', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 500.00);
      expect(tx.sender, 'KWAME ADJEI (0551234567)');
      expect(tx.reference, '8892035390');
      expect(tx.type, 'Income');
      expect(tx.category, 'Income');
    });

    // ==========================================
    // Vodafone / Telecel Cash
    // ==========================================
    test('Vodafone Cash - Payment', () {
      const body = "Payment of GHS 30.00 to SHOPRITE successful. New balance: GHS 150.00. Ref: VC7729384.";
      final tx = SmsParser.parse(body, 'Vodafone Cash', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 30.00);
      expect(tx.merchant, 'SHOPRITE');
      expect(tx.reference, isNull); // Removed 'Ref' from generic extraction
      expect(tx.type, 'Expense');
      expect(tx.provider, 'Telecel'); // Mapped via identifyProvider
    });

    test('Vodafone Cash - Cash Out', () {
      const body = "You have withdrawn GHS 100.00 at Agent AMA'S ENTERPRISE. New balance: GHS 50.00. Ref: VC7729401.";
      final tx = SmsParser.parse(body, 'Vodafone Cash', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 100.00);
      expect(tx.merchant, "AMA'S ENTERPRISE");
      expect(tx.reference, isNull);
      expect(tx.type, 'Withdrawal');
      expect(tx.category, 'Cash Withdrawal');
    });

    test('Vodafone Cash - Transfer', () {
      const body = "You have transferred GHS 80.00 to YAW BOATENG. New balance: GHS 170.00. Ref: VC7729450.";
      final tx = SmsParser.parse(body, 'Vodafone Cash', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 80.00);
      expect(tx.receiver, 'YAW BOATENG');
      expect(tx.reference, isNull);
      expect(tx.type, 'Transfer');
    });

    test('Vodafone Cash - Income', () {
      const body = "You have received GHS 250.00 from AKOSUA MENSAH. New balance: GHS 250.00. Ref: VC7729500.";
      final tx = SmsParser.parse(body, 'Vodafone Cash', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 250.00);
      expect(tx.sender, 'AKOSUA MENSAH');
      expect(tx.reference, isNull);
      expect(tx.type, 'Income');
    });

    // ==========================================
    // AirtelTigo Money
    // ==========================================
    test('AirtelTigo Money - Payment', () {
      const body = "You have made a payment of GHS 25.00 to MELCOM. Balance: GHS 95.00. Trans ID: AT5512309.";
      final tx = SmsParser.parse(body, 'AirtelTigo Money', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 25.00);
      expect(tx.merchant, 'MELCOM');
      expect(tx.reference, isNull);
      expect(tx.type, 'Expense');
      expect(tx.provider, 'AirtelTigo');
    });

    test('AirtelTigo Money - Cash Out', () {
      const body = "Cash withdrawal of GHS 150.00 successful at Agent NANA'S SHOP. Balance: GHS 40.00. Trans ID: AT5512350.";
      final tx = SmsParser.parse(body, 'AirtelTigo Money', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 150.00);
      expect(tx.merchant, "NANA'S SHOP");
      expect(tx.reference, isNull);
      expect(tx.type, 'Withdrawal');
      expect(tx.category, 'Cash Withdrawal');
    });

    test('AirtelTigo Money - Transfer', () {
      const body = "You have sent GHS 60.00 to KOJO ANTWI. Balance: GHS 130.00. Trans ID: AT5512400.";
      final tx = SmsParser.parse(body, 'AirtelTigo Money', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 60.00);
      expect(tx.receiver, 'KOJO ANTWI');
      expect(tx.reference, isNull);
      expect(tx.type, 'Transfer');
    });

    test('AirtelTigo Money - Income', () {
      const body = "You have received GHS 300.00 from ESI DANQUAH. Balance: GHS 300.00. Trans ID: AT5512450.";
      final tx = SmsParser.parse(body, 'AirtelTigo Money', timestamp);

      expect(tx, isNotNull);
      expect(tx!.amount, 300.00);
      expect(tx.sender, 'ESI DANQUAH');
      expect(tx.reference, isNull);
      expect(tx.type, 'Income');
    });

    // ==========================================
    // Custom Rules Auto-Learning Check
    // ==========================================
    test('Should prioritize custom rules for categorization', () {
      const body = "You have made a payment of GHS 25.00 to RANDOM SHOP XYZ. Balance: GHS 95.00. Trans ID: AT9999.";
      
      // Normally RANDOM SHOP XYZ would be Uncategorized
      final defaultTx = SmsParser.parse(body, 'AirtelTigo Money', timestamp);
      expect(defaultTx!.category, 'Uncategorized');

      // Now pass custom rule mapped to normalized counterparty
      final customRules = {
        'RANDOM SHOP XYZ': 'Shopping'
      };
      
      final learnedTx = SmsParser.parse(body, 'AirtelTigo Money', timestamp, customRules: customRules);
      expect(learnedTx!.category, 'Shopping');
    });

  });
}

