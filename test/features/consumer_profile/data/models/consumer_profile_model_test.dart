import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/features/consumer_profile/data/models/consumer_profile_model.dart';

void main() {
  group('ConsumerProfileModel', () {
    test('fromJson desserializa corretamente com address', () {
      final json = {
        'id': '123',
        'user': {
          'id': '456',
          'name': 'João Silva',
          'email': 'joao@test.com',
          'phone': '11999999999',
        },
        'address': {
          'id': 'addr_1',
          'street': 'Rua das Flores',
          'number': '42',
          'city': 'São Paulo',
          'state': 'SP',
          'zip_code': '01234567',
          'is_primary': true,
        },
      };

      final model = ConsumerProfileModel.fromJson(json);

      expect(model.id, '123');
      expect(model.userId, '456');
      expect(model.name, 'João Silva');
      expect(model.email, 'joao@test.com');
      expect(model.phone, '11999999999');
      expect(model.address, 'Rua das Flores, 42, São Paulo');
    });

    test('fromJson desserializa corretamente sem address', () {
      final json = {
        'id': '123',
        'user': {'id': '456', 'name': 'Maria', 'email': 'maria@test.com'},
      };

      final model = ConsumerProfileModel.fromJson(json);

      expect(model.id, '123');
      expect(model.userId, '456');
      expect(model.name, 'Maria');
      expect(model.email, 'maria@test.com');
      expect(model.address, '');
    });

    test('mock() cria instância válida', () {
      final model = ConsumerProfileModel.mock();

      expect(model.id, 'consumer_1');
      expect(model.userId, 'user_1');
      expect(model.name, 'Ricardo Aguiar');
      expect(model.email, 'ricardo.aguiar@ragro.com.br');
    });
  });
}
