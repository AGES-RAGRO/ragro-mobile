import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/features/producer_profile/data/models/producer_update_request.dart';
import 'package:ragro_mobile/features/producer_profile/data/models/public_producer_model.dart';

void main() {
  group('PublicProducerModel.fromJson', () {
    test('parseia ProducerPublicProfileResponse real do backend', () {
      // Shape real retornado por GET /producers/{id}/profile
      // Com @PreAuthorize("hasRole('CUSTOMER')")
      final json = {
        'id': 'abc-123',
        'name': 'João Silva',
        'phone': '+55 51 99999-0001',
        'farmName': 'Fazenda Sol Nascente',
        'description': 'Orgânicos frescos',
        'story': 'Três gerações no campo',
        'photoUrl': 'https://s3.example.com/photo.jpg',
        'avatarS3': 'https://s3.example.com/avatar.jpg',
        'displayPhotoS3': 'https://s3.example.com/cover.jpg',
        'averageRating': 4.8,
        'totalReviews': 120,
        'memberSince': '2020-03-15',
        'address': {
          'street': 'Rua das Flores',
          'number': '123',
          'city': 'Porto Alegre',
          'state': 'RS',
          'zipCode': '90010120',
        },
        'availability': [
          {'weekday': 1, 'opensAt': '14:00', 'closesAt': '18:30'},
        ],
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
      expect(model.memberSince, DateTime(2020, 3, 15));
      expect(model.location, 'Porto Alegre, RS');
      // Availability é incluído na resposta
      expect(model.availability, isNotEmpty);
      expect(model.availability.length, 1);
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

    test('parseia resposta camelCase com photoUrl opcional', () {
      final json = {
        'id': 'abc-456',
        'name': 'Maria Santos',
        'phone': '+55 51 88888-0002',
        'farmName': 'Fazenda Esperança',
        'description': 'Bio fresh',
        'story': 'Desde 2010',
        'avatarS3': 'https://s3.example.com/a.jpg',
        'displayPhotoS3': 'https://s3.example.com/c.jpg',
        'photoUrl': 'https://s3.example.com/photo.jpg',
        'averageRating': 4.5,
        'totalReviews': 50,
        'memberSince': '2019-06-01',
        'address': {'city': 'Canela', 'state': 'RS'},
      };

      final model = PublicProducerModel.fromJson(json);

      expect(model.name, 'Maria Santos');
      expect(model.farmName, 'Fazenda Esperança');
      expect(model.avatarUrl, 'https://s3.example.com/a.jpg');
      expect(model.coverUrl, 'https://s3.example.com/c.jpg');
      expect(model.photoUrl, 'https://s3.example.com/photo.jpg');
      expect(model.averageRating, 4.5);
      expect(model.totalReviews, 50);
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
