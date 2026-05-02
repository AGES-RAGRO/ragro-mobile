import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/shared/utils/unity_type_label.dart';

void main() {
  group('localizeUnityType', () {
    test('traduz unidades em inglês para abreviações pt-BR', () {
      expect(localizeUnityType('unit'), 'unidade');
      expect(localizeUnityType('box'), 'caixa');
      expect(localizeUnityType('liter'), 'litro');
      expect(localizeUnityType('dozen'), 'dúzia');
    });

    test('mantém unidades já universais', () {
      expect(localizeUnityType('kg'), 'kg');
      expect(localizeUnityType('g'), 'g');
      expect(localizeUnityType('ml'), 'ml');
    });

    test('é case-insensitive', () {
      expect(localizeUnityType('UNIT'), 'unidade');
      expect(localizeUnityType('Box'), 'caixa');
      expect(localizeUnityType('LITER'), 'litro');
    });

    test('ignora espaços ao redor', () {
      expect(localizeUnityType('  unit  '), 'unidade');
    });

    test('retorna vazio para entrada vazia', () {
      expect(localizeUnityType(''), '');
    });

    test('retorna o valor original quando não reconhecido', () {
      expect(localizeUnityType('xyz'), 'xyz');
      expect(localizeUnityType('saco'), 'saco');
    });
  });
}
