import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/confirm_customer_delivery.dart';

class MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late ConfirmCustomerDelivery useCase;
  late MockOrdersRepository repo;

  setUp(() {
    repo = MockOrdersRepository();
    useCase = ConfirmCustomerDelivery(repo);
  });

  final OrderDetail tConfirmed = OrderDetail(
    id: 'order-1',
    orderNumber: '#0001',
    status: 'DELIVERED',
    statusLabel: 'Entregue',
    createdAt: DateTime(2026, 5, 5),
    producerId: 'p1',
    producerName: 'Fazenda Teste',
    producerPhone: '5199999',
    producerPicture: null,
    items: const [],
    totalAmount: 0,
    deliveryAddress: const OrderDetailAddress(
      street: 'Rua A',
      number: '1',
      complement: '',
      neighborhood: 'Centro',
      city: 'Porto Alegre',
      state: 'RS',
      reference: '',
    ),
    actions: const OrderDetailActions(
      canConfirmDelivery: false,
      canCancel: false,
      canContactProducer: true,
    ),
  );

  group('ConfirmCustomerDelivery', () {
    test('repassa orderId para o repository e devolve OrderDetail', () async {
      when(
        () => repo.confirmCustomerDelivery(any()),
      ).thenAnswer((_) async => tConfirmed);

      final result = await useCase('order-1');

      expect(result.id, 'order-1');
      expect(result.status, 'DELIVERED');
      expect(result.canConfirmDelivery, isFalse);
      verify(() => repo.confirmCustomerDelivery('order-1')).called(1);
    });

    test('propaga NotFoundException quando endpoint backend ainda não existe (bug C2)', () async {
      when(
        () => repo.confirmCustomerDelivery(any()),
      ).thenThrow(const NotFoundException());

      expect(
        () => useCase('order-x'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
