import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/features/customer_profile/data/models/customer_profile_model.dart';

void main() {
  group('CustomerProfileModel', () {
    group('fromJson', () {
      test('deserializes correctly with populated addresses list', () {
        // Arrange — backend returns camelCase (Jackson default, no @JsonProperty)
        final json = <String, dynamic>{
          'id': 'customer-uuid-123',
          'name': 'João Silva',
          'email': 'joao@example.com',
          'phone': '(51) 98765-4321',
          'active': true,
          'addresses': [
            <String, dynamic>{
              'id': 'addr-uuid-001',
              'street': 'Rua das Flores',
              'number': '123',
              'city': 'Porto Alegre',
              'state': 'RS',
              'zipCode': '90010120',
              'isPrimary': true,
            },
          ],
        };

        // Act
        final model = CustomerProfileModel.fromJson(json);

        // Assert
        expect(model.id, 'customer-uuid-123');
        expect(model.name, 'João Silva');
        expect(model.email, 'joao@example.com');
        expect(model.phone, '(51) 98765-4321');
        expect(model.active, isTrue);
        expect(model.addresses, hasLength(1));
        expect(model.addresses.first.zipCode, '90010120');
        expect(model.addresses.first.isPrimary, isTrue);
      });

      test('deserializes correctly when addresses field is null', () {
        // Arrange
        final json = <String, dynamic>{
          'id': 'customer-uuid-456',
          'name': 'Maria Souza',
          'email': 'maria@example.com',
          'addresses': null,
        };

        // Act
        final model = CustomerProfileModel.fromJson(json);

        // Assert
        expect(model.addresses, isEmpty);
      });

      test('deserializes correctly when addresses list is empty', () {
        // Arrange
        final json = <String, dynamic>{
          'id': 'customer-uuid-789',
          'name': 'Carlos Lima',
          'email': 'carlos@example.com',
          'addresses': <dynamic>[],
        };

        // Act
        final model = CustomerProfileModel.fromJson(json);

        // Assert
        expect(model.addresses, isEmpty);
      });

      test('applies default values for optional fields', () {
        // Arrange — phone and active omitted
        final json = <String, dynamic>{
          'id': 'customer-uuid-000',
          'name': 'Ana Costa',
          'email': 'ana@example.com',
        };

        // Act
        final model = CustomerProfileModel.fromJson(json);

        // Assert
        expect(model.phone, '');
        expect(model.active, isTrue);
        expect(model.addresses, isEmpty);
      });
    });

    group('primaryAddress', () {
      test('returns address with isPrimary=true when multiple addresses exist',
          () {
        // Arrange — two addresses, second one is primary
        final json = <String, dynamic>{
          'id': 'customer-uuid-abc',
          'name': 'Pedro Alves',
          'email': 'pedro@example.com',
          'addresses': [
            <String, dynamic>{
              'id': 'addr-secondary',
              'street': 'Rua Secundária',
              'number': '10',
              'city': 'Curitiba',
              'state': 'PR',
              'zipCode': '80000000',
              'isPrimary': false,
            },
            <String, dynamic>{
              'id': 'addr-primary',
              'street': 'Rua Principal',
              'number': '99',
              'city': 'Curitiba',
              'state': 'PR',
              'zipCode': '80100000',
              'isPrimary': true,
            },
          ],
        };

        // Act
        final model = CustomerProfileModel.fromJson(json);

        // Assert
        expect(model.primaryAddress, isNotNull);
        expect(model.primaryAddress!.id, 'addr-primary');
      });

      test('returns null when addresses list is empty', () {
        // Arrange
        final json = <String, dynamic>{
          'id': 'customer-uuid-empty',
          'name': 'Sem Endereço',
          'email': 'sem@example.com',
          'addresses': <dynamic>[],
        };

        // Act
        final model = CustomerProfileModel.fromJson(json);

        // Assert
        expect(model.primaryAddress, isNull);
      });
    });
  });
}
