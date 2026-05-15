import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/features/cart/data/models/cart_item_model.dart';
import 'package:ragro_mobile/features/cart/data/models/cart_model.dart';

void main() {
  group('CartItemModel', () {
    group('fromJson', () {
      test('deserializa todos os campos do CartItemResponse', () {
        final json = <String, dynamic>{
          'id': 'cart-item-uuid-1',
          'productId': 'product-uuid-1',
          'productName': 'Morango Orgânico',
          'unitPrice': 15.50,
          'imageS3': 'https://example.com/morango.jpg',
          'unityType': 'kg',
          'quantity': 2.5,
          'subtotal': 38.75,
        };

        final model = CartItemModel.fromJson(json);

        expect(model.id, 'cart-item-uuid-1');
        expect(model.productId, 'product-uuid-1');
        expect(model.productName, 'Morango Orgânico');
        expect(model.unitPrice, 15.50);
        expect(model.imageUrl, 'https://example.com/morango.jpg');
        expect(model.unityType, 'kg');
        expect(model.quantity, 2.5);
        expect(model.subtotal, 38.75);
        expect(model.totalPrice, 38.75);
      });

      test('aplica defaults quando campos opcionais vêm ausentes', () {
        // unityType, productName e imageS3 são tolerantes a ausência
        final json = <String, dynamic>{
          'id': 'cart-item-uuid-2',
          'productId': 'product-uuid-2',
          'unitPrice': 8,
          'quantity': 1,
          'subtotal': 8,
        };

        final model = CartItemModel.fromJson(json);

        expect(model.productName, '');
        expect(model.imageUrl, '');
        expect(model.unityType, '');
      });

      test('converte quantity inteira retornada como num para double', () {
        final json = <String, dynamic>{
          'id': 'id',
          'productId': 'p',
          'productName': 'X',
          'unitPrice': 10,
          'imageS3': '',
          'unityType': 'un',
          'quantity': 3,
          'subtotal': 30,
        };

        final model = CartItemModel.fromJson(json);

        expect(model.quantity, 3.0);
        expect(model.unitPrice, 10.0);
        expect(model.subtotal, 30.0);
      });
    });
  });

  group('CartModel', () {
    group('fromJson', () {
      test('deserializa carrinho com items', () {
        final json = <String, dynamic>{
          'id': 'cart-uuid',
          'farmerId': 'farmer-uuid',
          'farmName': 'Sítio Boa Vista',
          'totalAmount': 96.70,
          'items': [
            <String, dynamic>{
              'id': 'item-1',
              'productId': 'p1',
              'productName': 'Morango',
              'unitPrice': 15.50,
              'imageS3': '',
              'unityType': 'kg',
              'quantity': 2.5,
              'subtotal': 38.75,
            },
          ],
        };

        final model = CartModel.fromJson(json);

        expect(model.id, 'cart-uuid');
        expect(model.producerId, 'farmer-uuid');
        expect(model.farmName, 'Sítio Boa Vista');
        expect(model.totalAmount, 96.70);
        expect(model.items, hasLength(1));
        expect(model.items.first.productId, 'p1');
        expect(model.isEmpty, isFalse);
      });

      test('deserializa carrinho com items ausente', () {
        final json = <String, dynamic>{
          'id': 'cart-empty',
          'farmerId': null,
          'farmName': null,
          'totalAmount': 0,
        };

        final model = CartModel.fromJson(json);

        expect(model.items, isEmpty);
        expect(model.isEmpty, isTrue);
        expect(model.producerId, '');
        expect(model.farmName, '');
        expect(model.totalAmount, 0.0);
      });

      test('CartModel.empty() é tratado como carrinho vazio', () {
        const empty = CartModel.empty();

        expect(empty.isEmpty, isTrue);
        expect(empty.items, isEmpty);
        expect(empty.id, '');
        expect(empty.totalAmount, 0);
      });
    });
  });
}
