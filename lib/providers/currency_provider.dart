import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

enum Currency {
  ghs(code: 'GHS', symbol: 'GH₵'),
  usd(code: 'USD', symbol: '\$'),
  eur(code: 'EUR', symbol: '€'),
  gbp(code: 'GBP', symbol: '£'),
  ngn(code: 'NGN', symbol: '₦'),
  zar(code: 'ZAR', symbol: 'R'),
  kes(code: 'KES', symbol: 'KSh'),
  egp(code: 'EGP', symbol: 'E£'),
  tzs(code: 'TZS', symbol: 'TSh'),
  ugx(code: 'UGX', symbol: 'USh'),
  etb(code: 'ETB', symbol: 'Br'),
  mad(code: 'MAD', symbol: 'MAD'),
  xof(code: 'XOF', symbol: 'CFA'),
  xaf(code: 'XAF', symbol: 'FCFA'),
  inr(code: 'INR', symbol: '₹'),
  cny(code: 'CNY', symbol: '¥'),
  jpy(code: 'JPY', symbol: '¥'),
  cad(code: 'CAD', symbol: 'CA\$'),
  aud(code: 'AUD', symbol: 'A\$'),
  brl(code: 'BRL', symbol: 'R\$'),
  mxn(code: 'MXN', symbol: 'MX\$'),
  aed(code: 'AED', symbol: 'AED'),
  sar(code: 'SAR', symbol: 'SAR'),
  sgd(code: 'SGD', symbol: 'S\$'),
  chf(code: 'CHF', symbol: 'CHF'),
  sek(code: 'SEK', symbol: 'kr'),
  nok(code: 'NOK', symbol: 'kr'),
  dkk(code: 'DKK', symbol: 'kr'),
  pkr(code: 'PKR', symbol: '₨'),
  bdt(code: 'BDT', symbol: '৳'),
  php(code: 'PHP', symbol: '₱'),
  idr(code: 'IDR', symbol: 'Rp'),
  myr(code: 'MYR', symbol: 'RM'),
  thb(code: 'THB', symbol: '฿'),
  vnd(code: 'VND', symbol: '₫'),
  krw(code: 'KRW', symbol: '₩'),
  twd(code: 'TWD', symbol: 'NT\$'),
  hkd(code: 'HKD', symbol: 'HK\$'),
  nzd(code: 'NZD', symbol: 'NZ\$'),
  rub(code: 'RUB', symbol: '₽'),
  tryLira(code: 'TRY', symbol: '₺'),
  pln(code: 'PLN', symbol: 'zł'),
  czk(code: 'CZK', symbol: 'Kč'),
  huf(code: 'HUF', symbol: 'Ft'),
  ron(code: 'RON', symbol: 'lei'),
  bgn(code: 'BGN', symbol: 'лв'),
  hrk(code: 'HRK', symbol: 'kn'),
  ars(code: 'ARS', symbol: 'AR\$'),
  clp(code: 'CLP', symbol: 'CL\$'),
  cop(code: 'COP', symbol: 'CO\$'),
  pen(code: 'PEN', symbol: 'S/.'),
  uyu(code: 'UYU', symbol: '\$U'),
  rwf(code: 'RWF', symbol: 'FRw'),
  zmw(code: 'ZMW', symbol: 'ZK'),
  bwp(code: 'BWP', symbol: 'P'),
  mwk(code: 'MWK', symbol: 'MK'),
  lkr(code: 'LKR', symbol: '₨'),
  mmk(code: 'MMK', symbol: 'K'),
  kzt(code: 'KZT', symbol: '₸'),
  uah(code: 'UAH', symbol: '₴'),
  ils(code: 'ILS', symbol: '₪'),
  qar(code: 'QAR', symbol: 'QR'),
  kwd(code: 'KWD', symbol: 'KD'),
  bhd(code: 'BHD', symbol: 'BD'),
  omr(code: 'OMR', symbol: 'OMR'),
  jod(code: 'JOD', symbol: 'JD'),
  dzd(code: 'DZD', symbol: 'DA'),
  tnd(code: 'TND', symbol: 'DT'),
  lyd(code: 'LYD', symbol: 'LD');

  final String code;
  final String symbol;
  const Currency({required this.code, required this.symbol});
}

/// Maps country names to their currency.
const Map<String, Currency> countryCurrencyMap = {
  // Africa
  'Ghana': Currency.ghs,
  'Nigeria': Currency.ngn,
  'South Africa': Currency.zar,
  'Kenya': Currency.kes,
  'Egypt': Currency.egp,
  'Tanzania': Currency.tzs,
  'Uganda': Currency.ugx,
  'Ethiopia': Currency.etb,
  'Morocco': Currency.mad,
  'Algeria': Currency.dzd,
  'Tunisia': Currency.tnd,
  'Libya': Currency.lyd,
  'Rwanda': Currency.rwf,
  'Zambia': Currency.zmw,
  'Botswana': Currency.bwp,
  'Malawi': Currency.mwk,
  'Senegal': Currency.xof,
  "Côte d'Ivoire": Currency.xof,
  'Mali': Currency.xof,
  'Burkina Faso': Currency.xof,
  'Benin': Currency.xof,
  'Togo': Currency.xof,
  'Guinea-Bissau': Currency.xof,
  'Niger': Currency.xof,
  'Cameroon': Currency.xaf,
  'Chad': Currency.xaf,
  'Central African Republic': Currency.xaf,
  'Republic of the Congo': Currency.xaf,
  'Gabon': Currency.xaf,
  'Equatorial Guinea': Currency.xaf,
  // Americas
  'United States': Currency.usd,
  'Canada': Currency.cad,
  'Brazil': Currency.brl,
  'Mexico': Currency.mxn,
  'Argentina': Currency.ars,
  'Chile': Currency.clp,
  'Colombia': Currency.cop,
  'Peru': Currency.pen,
  'Uruguay': Currency.uyu,
  // Europe
  'United Kingdom': Currency.gbp,
  'Germany': Currency.eur,
  'France': Currency.eur,
  'Italy': Currency.eur,
  'Spain': Currency.eur,
  'Portugal': Currency.eur,
  'Netherlands': Currency.eur,
  'Belgium': Currency.eur,
  'Austria': Currency.eur,
  'Greece': Currency.eur,
  'Ireland': Currency.eur,
  'Finland': Currency.eur,
  'Luxembourg': Currency.eur,
  'Switzerland': Currency.chf,
  'Sweden': Currency.sek,
  'Norway': Currency.nok,
  'Denmark': Currency.dkk,
  'Poland': Currency.pln,
  'Czech Republic': Currency.czk,
  'Hungary': Currency.huf,
  'Romania': Currency.ron,
  'Bulgaria': Currency.bgn,
  'Croatia': Currency.hrk,
  'Ukraine': Currency.uah,
  'Russia': Currency.rub,
  'Turkey': Currency.tryLira,
  // Middle East
  'United Arab Emirates': Currency.aed,
  'Saudi Arabia': Currency.sar,
  'Qatar': Currency.qar,
  'Kuwait': Currency.kwd,
  'Bahrain': Currency.bhd,
  'Oman': Currency.omr,
  'Jordan': Currency.jod,
  'Israel': Currency.ils,
  // Asia
  'India': Currency.inr,
  'China': Currency.cny,
  'Japan': Currency.jpy,
  'South Korea': Currency.krw,
  'Singapore': Currency.sgd,
  'Hong Kong': Currency.hkd,
  'Taiwan': Currency.twd,
  'Malaysia': Currency.myr,
  'Thailand': Currency.thb,
  'Indonesia': Currency.idr,
  'Philippines': Currency.php,
  'Vietnam': Currency.vnd,
  'Pakistan': Currency.pkr,
  'Bangladesh': Currency.bdt,
  'Sri Lanka': Currency.lkr,
  'Myanmar': Currency.mmk,
  'Kazakhstan': Currency.kzt,
  // Oceania
  'Australia': Currency.aud,
  'New Zealand': Currency.nzd,
};

/// Returns a sorted list of all supported country names.
List<String> get supportedCountries =>
    countryCurrencyMap.keys.toList()..sort();

/// Looks up the [Currency] for a given [country]. Falls back to USD if unknown.
Currency currencyForCountry(String country) =>
    countryCurrencyMap[country] ?? Currency.usd;

final currencyProvider =
    StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  return CurrencyNotifier();
});

class CurrencyNotifier extends StateNotifier<Currency> {
  CurrencyNotifier() : super(_loadInitialCurrency());

  static Currency _loadInitialCurrency() {
    final code =
        StorageService.settingsBox.get('currency_code', defaultValue: 'ghs');
    return Currency.values.firstWhere(
      (c) => c.name == code,
      orElse: () => Currency.ghs,
    );
  }

  Future<void> setCurrency(Currency currency) async {
    state = currency;
    await StorageService.settingsBox.put('currency_code', currency.name);
  }

  /// Infers and sets the currency based on the user's selected country.
  Future<void> setCurrencyFromCountry(String country) async {
    await setCurrency(currencyForCountry(country));
  }
}
