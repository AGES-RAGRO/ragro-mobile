import 'package:flutter/services.dart';

// Máscaras dinâmicas para campos de entrada. Aplicadas via `inputFormatters`
// para autoformatar enquanto o usuário digita, mantendo apenas dígitos no
// valor interno e inserindo separadores conforme o length.

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _digits(newValue.text, max: 11);
    final formatted = _format(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _digits(newValue.text, max: 11);
    final formatted = _format(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(String digits) {
    if (digits.isEmpty) return '';
    final buffer = StringBuffer('(');
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _digits(newValue.text, max: 8);
    final formatted = digits.length > 5
        ? '${digits.substring(0, 5)}-${digits.substring(5)}'
        : digits;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String _digits(String input, {required int max}) {
  final only = input.replaceAll(RegExp(r'\D'), '');
  return only.length > max ? only.substring(0, max) : only;
}

class CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _digits(newValue.text, max: 14);
    final formatted = _formatCnpj(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCnpj(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('/');
      if (i == 12) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

/// Formatter adaptativo: aplica máscara CPF (11 dígitos) ou CNPJ (14 dígitos)
/// conforme o comprimento digitado. Enquanto <= 11 dígitos: 000.000.000-00.
/// A partir do 12º dígito muda para 00.000.000/0000-00.
class FiscalNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _digits(newValue.text, max: 14);
    final formatted = digits.length <= 11
        ? _formatCpf(digits)
        : _formatCnpj(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCpf(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  String _formatCnpj(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('/');
      if (i == 12) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
