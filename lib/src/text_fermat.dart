import 'package:intl/intl.dart';

extension CustomStringAmount on String {
  String formattedAmount({bool? withSymbol}) {
    withSymbol ??= true;
    double value = parseToDouble();
    var summa = _thousandDecimalFormat(value);
    if (withSymbol) {
      summa += " so‘m";
    }
    return summa;
  }

  double parseToDouble() {
    try {
      String cleaned = replaceAll(' ', '')
          .replaceAll(',', '.')
          .replaceAll(RegExp(r'[^0-9.\-]'), '');
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }

  int parseToInt() {
    try {
      String cleaned = replaceAll(' ', '').replaceAll(RegExp(r'[^0-9\-]'), '');
      return int.parse(cleaned);
    } catch (e) {
      return 0;
    }
  }

  String _thousandDecimalFormat(double amount) {
    final formatter = NumberFormat("#,###.##", "en_US");
    return formatter.format(amount).replaceAll(",", " ");
  }
}
