import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/features/orders/data/models/order_detail_model.dart';

void main() {
  group('OrderDetailModel.fromJson', () {
    test('parses backend CustomerOrderResponse payload (canonical names)', () {
      final json = <String, dynamic>{
        'id': 'order-1',
        'status': 'PENDING',
        'createdAt': '2025-05-01T10:00:00Z',
        'producerId': 'producer-1',
        'producerName': 'Sítio Boa Vista',
        'producerPhone': '+5511999998888',
        'producerPicture': 'https://cdn/photo.jpg',
        'totalAmount': 150.50,
        'deliveryAddress': {
          'street': 'Rua A',
          'number': '100',
          'complement': 'Apto 2',
          'neighborhood': 'Centro',
          'city': 'São Paulo',
          'state': 'SP',
          'zipCode': '01000-000',
        },
        'items': [
          {
            'id': 'item-1',
            'productId': 'p-1',
            'productName': 'Tomate',
            'quantity': 2,
            'unityType': 'kg',
            'unitPrice': 10.0,
            'subtotal': 20.0,
          },
        ],
      };

      final model = OrderDetailModel.fromJson(json);

      expect(model.id, 'order-1');
      expect(model.producerPicture, 'https://cdn/photo.jpg');
      expect(model.producerPhone, '+5511999998888');
      expect(model.totalAmount, 150.50);
      expect(model.deliveryAddress.street, 'Rua A');
      expect(model.deliveryAddress.city, 'São Paulo');
      expect(model.deliveryAddress.zipCode, '01000-000');
      expect(model.items, hasLength(1));
      expect(model.items.first.productName, 'Tomate');
    });

    test('falls back to alternative field names (price/total, snake_case)', () {
      final json = <String, dynamic>{
        'id': 'order-2',
        'status': 'CONFIRMED',
        'producerName': 'Fazenda X',
        'producerPhotoUrl': 'https://cdn/alt.jpg',
        'price': 99.9,
        'deliveryAddress': {
          'street': 'Rua B',
          'number': '50',
          'neighborhood': 'Jardim',
          'city': 'Campinas',
          'state': 'SP',
          'zip_code': '13000-000',
        },
        'items': const <Map<String, dynamic>>[],
      };

      final model = OrderDetailModel.fromJson(json);

      expect(model.producerPicture, 'https://cdn/alt.jpg');
      expect(model.totalAmount, 99.9);
      expect(model.deliveryAddress.zipCode, '13000-000');
      expect(model.deliveryAddress.city, 'Campinas');
    });

    test('returns safe defaults when fields are missing or null', () {
      final json = <String, dynamic>{
        'id': 'order-3',
        'status': 'PENDING',
      };

      final model = OrderDetailModel.fromJson(json);

      expect(model.producerPicture, isNull);
      expect(model.producerPhone, isNull);
      expect(model.totalAmount, 0.0);
      expect(model.deliveryAddress.street, '');
      expect(model.deliveryAddress.zipCode, '');
      expect(model.items, isEmpty);
    });
  });
}
