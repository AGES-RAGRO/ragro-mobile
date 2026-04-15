import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/features/producer_profile/data/models/producer_update_request.dart';
import 'package:ragro_mobile/features/producer_profile/data/models/public_producer_model.dart';

void main() {
  group('PublicProducerModel.fromJson', () {
    test('parseia ProducerGetResponse real do backend (EPIC 1 camelCase)', () {
      // Shape real retornado por GET /producers/{id} — ProducerGetResponse.java
      final json = {
        'id': 'abc-123',
        'name': 'João Silva',
        'email': 'joao@example.com',
        'phone': '+55 51 99999-0001',
        'fiscalNumber': '12345678901',
        'fiscalNumberType': 'CPF',
        'farmName': 'Fazenda Sol Nascente',
        'description': 'Orgânicos frescos',
        'story': 'Três gerações no campo',
        'avatarS3': 'https://s3.example.com/avatar.jpg',
        'displayPhotoS3': 'https://s3.example.com/cover.jpg',
        'averageRating': 4.8,
        'totalReviews': 120,
        'totalOrders': 500,
        'totalSalesAmount': 15000.00,
        'memberSince': '2020-03-15',
        'active': true,
        'address': {
          'id': 'addr-1',
          'street': 'Rua das Flores',
          'number': '123',
          'city': 'Porto Alegre',
          'state': 'RS',
          'zipCode': '90010120',
          'isPrimary': true,
        },
        'paymentMethods': <dynamic>[],
      };

      final model = PublicProducerModel.fromJson(json);

      expect(model.id, 'abc-123');
      expect(model.name, 'João Silva');
      expect(model.phone, '+55 51 99999-0001');
      expect(model.farmName, 'Fazenda Sol Nascente');
      expect(model.avatarUrl, 'https://s3.example.com/avatar.jpg');
      expect(model.coverUrl, 'https://s3.example.com/cover.jpg');
      expect(model.averageRating, 4.8);
      expect(model.totalReviews, 120);
      expect(model.totalOrders, 500);
      expect(model.memberSince, DateTime(2020, 3, 15));
      expect(model.location, 'Porto Alegre, RS');
      // Endpoint não retorna products nem availability — listas vazias por default.
      expect(model.products, isEmpty);
      expect(model.availability, isEmpty);
    });

    test('usa apenas city quando state está ausente no address', () {
      final json = {
        'id': 'abc-789',
        'name': 'Ana',
        'phone': '',
        'farmName': 'Sítio',
        'address': {'city': 'Curitiba'},
      };

      final model = PublicProducerModel.fromJson(json);

      expect(model.location, 'Curitiba');
    });

    test('location vazio quando address ausente e sem fallback', () {
      final json = {
        'id': 'abc-000',
        'name': 'Sem endereço',
        'phone': '',
        'farmName': 'Fazenda X',
      };

      final model = PublicProducerModel.fromJson(json);

      expect(model.location, '');
    });

    test('parseia resposta snake_case legada (fallback mock)', () {
      final json = {
        'id': 'abc-456',
        'name': 'Maria Santos',
        'phone': '+55 51 88888-0002',
        'farm_name': 'Fazenda Esperança',
        'description': 'Bio fresh',
        'story': 'Desde 2010',
        'avatar_s3': 'https://s3.example.com/a.jpg',
        'display_photo_s3': 'https://s3.example.com/c.jpg',
        'average_rating': 4.5,
        'total_reviews': 50,
        'total_orders': 200,
        'created_at': '2019-06-01',
        'location': 'Canela, RS',
      };

      final model = PublicProducerModel.fromJson(json);

      expect(model.name, 'Maria Santos');
      expect(model.farmName, 'Fazenda Esperança');
      expect(model.avatarUrl, 'https://s3.example.com/a.jpg');
      expect(model.averageRating, 4.5);
      expect(model.memberSince, DateTime(2019, 6));
      expect(model.location, 'Canela, RS');
    });
  });

  group('ProducerUpdateRequest.toJson', () {
    test('serializa farmName em camelCase e exclui campos nulos', () {
      const request = ProducerUpdateRequest(
        name: 'João Silva',
        farmName: 'Fazenda Nova',
        story: 'Minha história',
        phone: '(51) 99999-0001',
      );

      final json = request.toJson();

      expect(json.containsKey('farmName'), isTrue);
      expect(json['farmName'], 'Fazenda Nova');
      expect(json.containsKey('location'), isFalse);
      expect(json.containsKey('description'), isFalse);
    });

    test('inclui apenas campos não nulos no payload', () {
      const request = ProducerUpdateRequest(name: 'Só nome');

      final json = request.toJson();

      expect(json.keys, contains('name'));
      expect(json.length, 1);
    });
  });
}
