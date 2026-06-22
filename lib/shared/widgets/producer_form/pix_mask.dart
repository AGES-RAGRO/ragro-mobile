import 'package:flutter/services.dart';
import 'package:ragro_mobile/core/formatters/input_masks.dart';

/// Mask applied to the pix key input/hydration for the given key type:
/// cpf/cnpj -> [FiscalNumberInputFormatter], phone -> [PhoneInputFormatter],
/// otherwise none.
TextInputFormatter? pixMaskFor(String? pixKeyType) {
  switch (pixKeyType) {
    case 'cpf':
    case 'cnpj':
      return FiscalNumberInputFormatter();
    case 'phone':
      return PhoneInputFormatter();
    default:
      return null;
  }
}

/// [pixMaskFor] wrapped as an `inputFormatters` list (empty when no mask).
List<TextInputFormatter> pixMaskListFor(String? pixKeyType) {
  final mask = pixMaskFor(pixKeyType);
  return mask != null ? [mask] : const [];
}

/// Hint shown on the pix key field for the given key type. [randomHint]
/// customizes the fallback text for random keys.
String pixKeyHint(String type, {String randomHint = 'Chave aleatória'}) {
  return switch (type) {
    'cpf' => '000.000.000-00',
    'cnpj' => '00.000.000/0000-00',
    'email' => 'email@exemplo.com',
    'phone' => '(XX) XXXXX-XXXX',
    _ => randomHint,
  };
}

/// Keyboard type for the pix key field for the given key type.
TextInputType pixKeyboardType(String type) {
  return switch (type) {
    'cpf' || 'cnpj' || 'phone' => TextInputType.number,
    'email' => TextInputType.emailAddress,
    _ => TextInputType.text,
  };
}
