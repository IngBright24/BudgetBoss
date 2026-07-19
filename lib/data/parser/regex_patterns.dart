class RegexPatterns {
  // ==========================================
  // MTN MoMo Patterns
  // ==========================================

  // Format 1: General payment (DEBIT)
  static final RegExp mtnPaymentReal1 = RegExp(
    r'Payment made for (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+to\s+(.*?)\s*\.?\s*Current Balance',
    caseSensitive: false,
  );

  // Format 2: Payment received (CREDIT)
  static final RegExp mtnIncomeReal1 = RegExp(
    r'Payment received for (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+from\s+(.*?)\s*\.?\s*Current Balance',
    caseSensitive: false,
  );

  // Format 3: Cash Out at agent (DEBIT)
  static final RegExp mtnCashOutReal1 = RegExp(
    r'Cash Out made for (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+to\s+(.*?)\s*\.?\s*Current Balance',
    caseSensitive: false,
  );

  // Format 4: Short payment variant (DEBIT)
  static final RegExp mtnPaymentReal2 = RegExp(
    r'Payment for (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+to\s+(.*?)\s*\.?\s*Current Balance',
    caseSensitive: false,
  );

  // Format 5: Cash In / Deposit (CREDIT)
  static final RegExp mtnIncomeReal2 = RegExp(
    r'Cash In received for (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+from\s+(.*?)\s*\.?\s*Current Balance',
    caseSensitive: false,
  );

  // Format 6: Airtime/data/bill payment confirmation (DEBIT)
  static final RegExp mtnPaymentReal3 = RegExp(
    r'Your payment of (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+to\s+(.*?)\s+has been completed at',
    caseSensitive: false,
  );

  // Payment/Expense: "Payment made for GHS 10.00 to STEPHEN ANGAMAH. Current Balance: GHS 388.02..."
  // Also handles legacy format: "You have paid GHS 45.00 to KOFI'S PROVISION SHOP. Your balance is..."
  static final RegExp mtnPayment = RegExp(
    r'(?:Payment made for|You have paid)\s+(GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+to\s+(.*?)(?:\.|\s+Current Balance|\s+Your balance)',
    caseSensitive: false,
  );

  // Cash Out: "Cash Out made for GHS 50.00 to Agent..."
  // Also handles: "You have withdrawn GHS 200.00 from Agent..."
  static final RegExp mtnCashOut = RegExp(
    r'(?:Cash Out made for|You have withdrawn)\s+(GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+(?:from Agent|to Agent|to|from)\s+(.*?)(?:\.|\s+Current Balance|\s+Your balance)',
    caseSensitive: false,
  );

  // Transfer: "Transfer made for GHS 100.00 to..." or "You have sent..."
  static final RegExp mtnTransfer = RegExp(
    r'(?:Transfer made for|You have sent)\s+(GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+to\s+(.*?)(?:\.|\s+Current Balance|\s+Your balance)',
    caseSensitive: false,
  );

  // New Transfer format: "0000013743611172 Confirmed. GHS71.00 sent to 0551073071 RYAN KOFI OFORI on MTN MOBILE MONEY..."
  static final RegExp mtnTransferNew = RegExp(
    r'Confirmed\.\s+(GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+sent to\s+(.*?)(?:\s+on\s+MTN|\.|\s+Current)',
    caseSensitive: false,
  );

  // Income/Deposit: "Payment received for GHS 500.00 from..." or "You have received..." or "Cash In received for..."
  // Also handles: "...Confirmed. You have received GHS1.00 from MTN MOBILE MONEY with transaction reference..."
  static final RegExp mtnIncome = RegExp(
    r'(?:Payment received for|You have received|Cash In received for|Transfer received for)\s+(GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+from\s+(.*?)(?:\.|\s+Current Balance|\s+Your balance|\s+with transaction)',
    caseSensitive: false,
  );


  // ==========================================
  // Vodafone Cash / Telecel Cash Patterns
  // ==========================================

  // Payment: "Payment of GHS 30.00 to SHOPRITE successful. New balance: GHS 150.00. Ref: VC7729384."
  static final RegExp vodaPayment = RegExp(
    r'Payment of (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+to\s+(.*?)\s+successful\.\s+New balance:\s+(?:GHS|GHC|USD)\s?[\d,]+\.?\d*\.\s+Ref:\s+([A-Za-z0-9]+)\.',
    caseSensitive: false,
  );

  // New Payment format: "0000013392985077 Confirmed. GHS101.99 paid to 125012 - PAYSTACK II on 2026-06-16 at 18:03:03. Your new Telecel Cash balance is..."
  static final RegExp vodaPaymentNew = RegExp(
    r'Confirmed\.\s+(GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+paid to\s+(.*?)\s+on\s+\d{4}-\d{2}-\d{2}',
    caseSensitive: false,
  );

  // Cash Out: "You have withdrawn GHS 100.00 at Agent AMA'S ENTERPRISE. New balance: GHS 50.00. Ref: VC7729401."
  static final RegExp vodaCashOut = RegExp(
    r'You have withdrawn (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+at Agent\s+(.*?)\.\s+New balance:\s+(?:GHS|GHC|USD)\s?[\d,]+\.?\d*\.\s+Ref:\s+([A-Za-z0-9]+)\.',
    caseSensitive: false,
  );

  // Transfer: "You have transferred GHS 80.00 to YAW BOATENG. New balance: GHS 170.00. Ref: VC7729450."
  static final RegExp vodaTransfer = RegExp(
    r'You have transferred (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+to\s+(.*?)\.\s+New balance:\s+(?:GHS|GHC|USD)\s?[\d,]+\.?\d*\.\s+Ref:\s+([A-Za-z0-9]+)\.',
    caseSensitive: false,
  );

  // Deposit: "You have received GHS 250.00 from AKOSUA MENSAH. New balance: GHS 250.00. Ref: VC7729500."
  static final RegExp vodaIncome = RegExp(
    r'You have received (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+from\s+(.*?)\.\s+New balance:\s+(?:GHS|GHC|USD)\s?[\d,]+\.?\d*\.\s+Ref:\s+([A-Za-z0-9]+)\.',
    caseSensitive: false,
  );

  // New Deposit format: "0000013524317163 Confirmed. On 2026-06-28 at 08:59:06, a deposit of GHS300.00 was made to your account from ROYAL BENERIC"
  static final RegExp vodaIncomeNew = RegExp(
    r'Confirmed\.\s+On\s+\d{4}-\d{2}-\d{2}.*?a deposit of\s+(GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+was made to your account from\s+(.*)',
    caseSensitive: false,
  );


  // ==========================================
  // AirtelTigo Money Patterns
  // ==========================================

  // Payment: "You have made a payment of GHS 25.00 to MELCOM. Balance: GHS 95.00. Trans ID: AT5512309."
  static final RegExp airtelPayment = RegExp(
    r'You have made a payment of (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+to\s+(.*?)\.\s+Balance:\s+(?:GHS|GHC|USD)\s?[\d,]+\.?\d*\.\s+Trans ID:\s+([A-Za-z0-9]+)\.',
    caseSensitive: false,
  );

  // Cash Out: "Cash withdrawal of GHS 150.00 successful at Agent NANA'S SHOP. Balance: GHS 40.00. Trans ID: AT5512350."
  static final RegExp airtelCashOut = RegExp(
    r'Cash withdrawal of (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+successful at Agent\s+(.*?)\.\s+Balance:\s+(?:GHS|GHC|USD)\s?[\d,]+\.?\d*\.\s+Trans ID:\s+([A-Za-z0-9]+)\.',
    caseSensitive: false,
  );

  // Transfer: "You have sent GHS 60.00 to KOJO ANTWI. Balance: GHS 130.00. Trans ID: AT5512400."
  static final RegExp airtelTransfer = RegExp(
    r'You have sent (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+to\s+(.*?)\.\s+Balance:\s+(?:GHS|GHC|USD)\s?[\d,]+\.?\d*\.\s+Trans ID:\s+([A-Za-z0-9]+)\.',
    caseSensitive: false,
  );

  // Deposit: "You have received GHS 300.00 from ESI DANQUAH. Balance: GHS 300.00. Trans ID: AT5512450."
  static final RegExp airtelIncome = RegExp(
    r'You have received (GHS|GHC|USD)\s?([\d,]+\.?\d*)\s+from\s+(.*?)\.\s+Balance:\s+(?:GHS|GHC|USD)\s?[\d,]+\.?\d*\.\s+Trans ID:\s+([A-Za-z0-9]+)\.',
    caseSensitive: false,
  );

  // ==========================================
  // Generic Bank Patterns
  // ==========================================
  
  // E.g. "debited GHS210.00", "deducted GHS 50", "purchase of"
  static final RegExp genericDebit = RegExp(
    r'(?:debited|deducted|withdrawn|purchase).*?(GHS|GHC|USD)\s?([\d,]+\.?\d*)',
    caseSensitive: false,
  );
  
  // E.g. "credited GHS 100.00", "deposited GHS50"
  static final RegExp genericCredit = RegExp(
    r'(?:credited|deposited|received).*?(GHS|GHC|USD)\s?([\d,]+\.?\d*)',
    caseSensitive: false,
  );
}

