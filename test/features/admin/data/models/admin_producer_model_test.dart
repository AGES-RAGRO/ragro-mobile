import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/features/admin/data/models/admin_producer_model.dart';

void main() {
  group('AdminProducerModel.fromJson', () {
    test('desserializa com address como objeto aninhado', () {
      final json = {
        'id': 'p1',
        'name': 'João Silva',
        'email': 'joao@test.com',
        'phone': '11999999999',
        'address': {
          'street': 'Rua das Flores',
          'number': '42',
          'city': 'São Paulo',
          'state': 'SP',
          'zipCode': '01234567',
          'complement': 'Apto 10',
          'neighborhood': 'Centro',
          'latitude': -23.5,
          'longitude': -46.6,
        },
        'createdAt': '2026-01-01T10:00:00Z',
        'updatedAt': '2026-02-01T10:00:00Z',
        'active': true,
        'fiscalNumber': '12345678901',
        'fiscalNumberType': 'CPF',
        'farmName': 'Fazenda Bela',
      };

      final model = AdminProducerModel.fromJson(json);

      expect(model.id, 'p1');
      expect(model.name, 'João Silva');
      expect(model.active, isTrue);
      expect(model.address, 'Rua das Flores, 42, São Paulo, SP');
      expect(model.producerAddress, isNotNull);
      expect(model.producerAddress!.street, 'Rua das Flores');
      expect(model.producerAddress!.zipCode, '01234567');
      expect(model.producerAddress!.complement, 'Apto 10');
      expect(model.producerAddress!.latitude, -23.5);
    });

    test('desserializa sem crashar quando campos opcionais são null', () {
      final json = {
        'id': 'p2',
        'name': 'Maria',
        'email': 'maria@test.com',
        'phone': '11988887777',
        'address': {
          'street': 'Rua A',
          'number': '1',
          'city': 'Rio',
          'state': 'RJ',
          'zipCode': '22000000',
        },
        'active': false,
      };

      final model = AdminProducerModel.fromJson(json);

      expect(model.id, 'p2');
      expect(model.active, isFalse);
      expect(model.fiscalNumber, '');
      expect(model.fiscalNumberType, '');
      expect(model.farmName, '');
      expect(model.producerAddress!.complement, isNull);
    });

    test('aplica fallback true quando active está ausente', () {
      final json = {
        'id': 'p3',
        'name': 'Carlos',
        'email': 'carlos@test.com',
        'phone': '11977776666',
        'address': {
          'street': 'Av. B',
          'number': '99',
          'city': 'BH',
          'state': 'MG',
          'zipCode': '30000000',
        },
      };

      final model = AdminProducerModel.fromJson(json);

      expect(model.active, isTrue);
    });

    test('tolera createdAt ausente usando DateTime.now()', () {
      final before = DateTime.now();
      final json = {
        'id': 'p4',
        'name': 'Ana',
        'email': 'ana@test.com',
        'phone': '11966665555',
        'address': {
          'street': 'Rua C',
          'number': '3',
          'city': 'Curitiba',
          'state': 'PR',
          'zipCode': '80000000',
        },
        'active': true,
      };

      final model = AdminProducerModel.fromJson(json);

      expect(
        model.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('desserializa address como String (backwards compat)', () {
      final json = {
        'id': 'p5',
        'name': 'Paulo',
        'email': 'paulo@test.com',
        'phone': '11955554444',
        'address': 'Rua Legacy, 10',
        'active': true,
      };

      final model = AdminProducerModel.fromJson(json);

      expect(model.address, 'Rua Legacy, 10');
      expect(model.producerAddress, isNull);
    });
  });
}
