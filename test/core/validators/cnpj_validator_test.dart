import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/core/validators/cnpj_validator.dart';

void main() {
  group('CnpjValidator', () {
    group('isValid — CNPJs válidos conhecidos', () {
      test('CNPJ válido sem máscara', () {
        expect(CnpjValidator.isValid('11222333000181'), isTrue);
      });

      test('CNPJ válido com máscara', () {
        expect(CnpjValidator.isValid('11.222.333/0001-81'), isTrue);
      });

      test('CNPJ válido — outro exemplo real', () {
        expect(CnpjValidator.isValid('45543915000181'), isTrue);
      });
    });

    group('isValid — CNPJs inválidos', () {
      test('Todos dígitos iguais são inválidos (00000000000000)', () {
        expect(CnpjValidator.isValid('00000000000000'), isFalse);
      });

      test('Comprimento menor que 14 dígitos', () {
        expect(CnpjValidator.isValid('1122233300018'), isFalse);
      });

      test('Comprimento maior que 14 dígitos', () {
        expect(CnpjValidator.isValid('112223330001811'), isFalse);
      });

      test('CNPJ com dígito verificador errado', () {
        expect(CnpjValidator.isValid('11222333000182'), isFalse);
      });

      test('String vazia', () {
        expect(CnpjValidator.isValid(''), isFalse);
      });

      test('Apenas letras', () {
        expect(CnpjValidator.isValid('abcdefghijklmn'), isFalse);
      });

      test('CPF (11 dígitos) não é CNPJ válido', () {
        expect(CnpjValidator.isValid('52998224725'), isFalse);
      });
    });
  });
}
