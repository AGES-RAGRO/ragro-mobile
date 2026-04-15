import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/core/formatters/input_masks.dart';

TextEditingValue _edit(String text) => TextEditingValue(text: text);

String _apply(TextInputFormatter formatter, String input) {
  return formatter.formatEditUpdate(_edit(''), _edit(input)).text;
}

void main() {
  group('CnpjInputFormatter', () {
    final fmt = CnpjInputFormatter();

    test('Formata 2 dígitos sem separador', () {
      expect(_apply(fmt, '11'), '11');
    });

    test('Formata 3 dígitos com ponto', () {
      expect(_apply(fmt, '112'), '11.2');
    });

    test('Formata 8 dígitos com dois pontos', () {
      expect(_apply(fmt, '11222333'), '11.222.333');
    });

    test('Formata 12 dígitos com barra', () {
      expect(_apply(fmt, '112223330001'), '11.222.333/0001');
    });

    test('Formata 14 dígitos completo', () {
      expect(_apply(fmt, '11222333000181'), '11.222.333/0001-81');
    });

    test('Ignora dígitos além de 14', () {
      expect(_apply(fmt, '112223330001819999'), '11.222.333/0001-81');
    });
  });

  group('FiscalNumberInputFormatter — modo adaptativo', () {
    final fmt = FiscalNumberInputFormatter();

    test('Até 11 dígitos usa máscara CPF', () {
      expect(_apply(fmt, '52998224725'), '529.982.247-25');
    });

    test('Com 12 dígitos muda para CNPJ (sem completar)', () {
      final result = _apply(fmt, '112223330001');
      expect(result, '11.222.333/0001');
    });

    test('14 dígitos usa máscara CNPJ completa', () {
      expect(_apply(fmt, '11222333000181'), '11.222.333/0001-81');
    });

    test('Strip de não-dígitos antes de formatar', () {
      expect(_apply(fmt, '529.982.247-25'), '529.982.247-25');
    });
  });
}
