import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,###", "en_US");

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted =
        _formatter.format(int.parse(newText)).replaceAll(',', ' ');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String formatAmount(int amount) {
    final formatter = NumberFormat("#,###", "en_US");
    return formatter.format(amount).replaceAll(',', ' ');
  }
}
