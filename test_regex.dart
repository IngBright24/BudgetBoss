import 'dart:core';

void main() {
  String format6 = "Your payment of GHS 11.00 to TELECEL PUSH has been completed at 2026-07-12 09:46:35. Your new balance: GHS 111.34. Fee was GHS 0.38 Tax was GHS -. Reference: BRIGHT TWUMASI-ANKRAH,233504806489,Data. Financial Transaction Id: 85223314605. External Transaction Id: 85223314605.";

  // User's proposed regex
  final regexUser = RegExp(
    r'(?:Financial Transaction Id|External Transaction Id|Transaction ID|Transaction Id)\s*[:\-]?\s*([0-9A-Z]{6,})|^\s*(\d{10,})\s+Confirmed', 
    caseSensitive: false
  );

  print("=== USER REGEX ===");
  final matchUser = regexUser.firstMatch(format6);
  if (matchUser != null) {
    print("ID: " + (matchUser.group(1) ?? matchUser.group(2) ?? ""));
  } else {
    print("NO MATCH");
  }

  // Vodafone and AirtelTigo also use the parser, so we can't just delete Ref! 
  // Let's see what happens if we use negative lookahead or strict ID formatting.
  // Vodafone IDs start with VC, AirtelTigo starts with AT.
  // Or simply only match Ref if it's followed by VC/AT or only numbers?
  // Since BRIGHT is matched, we can enforce that Ref: must be followed by digits or specific prefix.
  // Example: r'(?:Financial Transaction Id|External Transaction Id|Transaction ID|Transaction Id|Trans ID)\s*[:\-]?\s*([0-9A-Z]{6,})|(?:Ref|Reference)\s*[:\-]?\s*(VC[0-9A-Z]+|AT[0-9A-Z]+|[\d]{6,})|^\s*(\d{10,})\s+Confirmed'
  final regexGeneric = RegExp(
    r'(?:Financial Transaction Id|External Transaction Id|Transaction ID|Transaction Id|Trans ID)\s*[:\-]?\s*([0-9A-Z]{6,})|(?:Ref|Reference)\s*[:\-]?\s*(VC[0-9A-Z]+|AT[0-9A-Z]+|[\d]{6,})|^\s*(\d{10,})\s+Confirmed', 
    caseSensitive: false
  );

  print("=== GENERIC REGEX ===");
  final matchGen = regexGeneric.firstMatch(format6);
  if (matchGen != null) {
    print("ID: " + (matchGen.group(1) ?? matchGen.group(2) ?? matchGen.group(3) ?? ""));
  } else {
    print("NO MATCH");
  }
}

