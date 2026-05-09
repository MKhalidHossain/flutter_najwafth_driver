import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
final _wholeCurrencyFormat = NumberFormat.currency(
  symbol: r'$',
  decimalDigits: 0,
);

String formatCurrency(num value) => _currencyFormat.format(value);

String formatWholeCurrency(num value) => _wholeCurrencyFormat.format(value);
