import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/get_customer_order_by_id.dart';

class MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late GetCustomerOrderById useCase;
  late MockOrdersRepository repo;

  final tOrderDetail = OrderDetail(
    id: 'order-detail-1',
    orderNumber: '#0001',
    status: 'PENDING',
    statusLabel: 'Pendente',
    createdAt: DateTime(2026, 5, 5),
    producerId: 'p1',
    producerName: 'Fazenda Teste',
    producerPhone: '5199999999',
    producerPicture: null,
    items: const [],
    totalAmount: 150.0,
    deliveryAddress: const OrderDetailAddress(
      street: 'Rua A',
      number: '123',
      complement: 'Apt 101',
      neighborhood: 'Centro',
      city: 'Porto Alegre',
      state: 'RS',
      reference: 'Próximo ao banco',
    ),
    actions: const OrderDetailActions(
      canConfirmDelivery: false,
      canCancel: true,
      canContactProducer: true,
    ),
  );

  setUp(() {
    repo = MockOrdersRepository();
    useCase = GetCustomerOrderById(repo);
  });

  group('GetCustomerOrderById', () {
    test('repassa orderId para o repository e retorna OrderDetail completo', () async {
      when(
        () => repo.getCustomerOrderById(any()),
      ).thenAnswer((_) async => tOrderDetail);

      final result = await useCase('order-detail-1');

      expect(result.id, 'order-detail-1');
      expect(result.orderNumber, '#0001');
      expect(result.status, 'PENDING');
      expect(result.producerName, 'Fazenda Teste');
      expect(result.deliveryAddress.city, 'Porto Alegre');
      expect(result.actions?.canCancel, isTrue);
      verify(() => repo.getCustomerOrderById('order-detail-1')).called(1);
    });

    test('retorna OrderDetail com items quando houver itens no pedido', () async {
      final orderWithItems = OrderDetail(
        id: 'order-detail-2',
        orderNumber: '#0002',
        status: 'PENDING',
        statusLabel: 'Pendente',
        createdAt: DateTime(2026, 5, 5),
        producerId: 'p1',
        producerName: 'Fazenda Teste',
        producerPhone: '5199999999',
        producerPicture: null,
        items: const [
          OrderDetailItem(
            id: 'item-1',
            productId: 'prod-1',
            productName: 'Tomate',
            productPhoto: 'http://example.com/tomate.jpg',
            quantity: 2.5,
            unityType: 'kg',
            unitPrice: 5.0,
            subtotal: 12.5,
          ),
        ],
        totalAmount: 12.5,
        deliveryAddress: const OrderDetailAddress(
          street: 'Rua A',
          number: '123',
          complement: 'Apt 101',
          neighborhood: 'Centro',
          city: 'Porto Alegre',
          state: 'RS',
          reference: 'Próximo ao banco',
        ),
        actions: const OrderDetailActions(
          canConfirmDelivery: false,
          canCancel: true,
          canContactProducer: true,
        ),
      );

      when(
        () => repo.getCustomerOrderById(any()),
      ).thenAnswer((_) async => orderWithItems);

      final result = await useCase('order-detail-2');

      expect(result.items, isNotEmpty);
      expect(result.items.first.productName, 'Tomate');
      expect(result.items.first.quantity, 2.5);
    });

    test('propaga NotFoundException quando order não existe', () async {
      when(
        () => repo.getCustomerOrderById(any()),
      ).thenThrow(const NotFoundException());

      expect(
        () => useCase('order-nonexistent'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('propaga UnauthorizedException quando ordem pertence a outro cliente', () async {
      when(
        () => repo.getCustomerOrderById(any()),
      ).thenThrow(const UnauthorizedException());

      expect(
        () => useCase('order-other-user'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('propaga NetworkException em caso de erro de conectividade', () async {
      when(
        () => repo.getCustomerOrderById(any()),
      ).thenThrow(const NetworkException());

      expect(
        () => useCase('order-detail-1'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
