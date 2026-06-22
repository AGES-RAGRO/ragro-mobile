import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_form_controllers.dart';

/// Mirrors the pix-key normalization shared by the admin-edit and
/// producer-edit submit flows: cpf / phone / cnpj keys are stored as digits
/// only, while email / random keys are sent verbatim.
///
/// This locks in the CNPJ branch (CodeRabbit #3/#8) so a masked CNPJ pix key
/// is normalized to digits instead of being sent with dots/slash/dash.
String normalizePixKey(String? pixKeyType, String raw) {
  return (pixKeyType == 'cpf' ||
          pixKeyType == 'phone' ||
          pixKeyType == 'cnpj')
      ? digitsOnly(raw)
      : raw;
}

void main() {
  group('pix key normalization', () {
    test('cnpj masked key is normalized to digits only', () {
      expect(
        normalizePixKey('cnpj', '11.222.333/0001-81'),
        '11222333000181',
      );
    });

    test('cpf masked key is normalized to digits only', () {
      expect(normalizePixKey('cpf', '529.982.247-25'), '52998224725');
    });

    test('phone masked key is normalized to digits only', () {
      expect(normalizePixKey('phone', '(11) 99999-8888'), '11999998888');
    });

    test('email key is sent verbatim', () {
      expect(
        normalizePixKey('email', 'produtor@exemplo.com'),
        'produtor@exemplo.com',
      );
    });

    test('random key is sent verbatim', () {
      const random = 'a1b2c3d4-e5f6-7890-ab12-cd34ef56ab78';
      expect(normalizePixKey('random', random), random);
    });
  });
}
