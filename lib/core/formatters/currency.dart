import 'package:intl/intl.dart';

final NumberFormat _currency = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: r'R$',
);

/// Formats [value] as pt-BR currency, e.g. `R$ 1.234,56` (the locale uses a
/// non-breaking space between the symbol and the amount).
String formatCurrency(num value) => _currency.format(value);
