import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/shared/utils/unity_type_label.dart';

void main() {
  group('localizeUnityType', () {
    test('traduz unidades em inglês para abreviações pt-BR', () {
      expect(localizeUnityType('unit'), 'un');
      expect(localizeUnityType('box'), 'caixa');
      expect(localizeUnityType('liter'), 'L');
      expect(localizeUnityType('dozen'), 'dz');
    });

    test('aceita variantes já abreviadas', () {
      expect(localizeUnityType('un'), 'un');
      expect(localizeUnityType('cx'), 'caixa');
      expect(localizeUnityType('l'), 'L');
      expect(localizeUnityType('dz'), 'dz');
    });

    test('mantém unidades já universais', () {
      expect(localizeUnityType('kg'), 'kg');
      expect(localizeUnityType('g'), 'g');
      expect(localizeUnityType('ml'), 'ml');
    });

    test('é case-insensitive', () {
      expect(localizeUnityType('UNIT'), 'un');
      expect(localizeUnityType('Box'), 'caixa');
      expect(localizeUnityType('LITER'), 'L');
    });

    test('ignora espaços ao redor', () {
      expect(localizeUnityType('  unit  '), 'un');
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
