import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/repeat_order.dart';

class MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late RepeatOrder useCase;
  late MockOrdersRepository repo;

  final tOrder = Order(
    id: 'order-1',
    orderNumber: 'ORD-001',
    producerId: 'p1',
    producerPhone: '5199999999',
    farmName: 'Fazenda Teste',
    farmAvatarUrl: 'http://example.com/avatar.jpg',
    ownerName: 'João Silva',
    items: const [],
    totalAmount: 150.0,
    status: OrderStatus.pending,
    createdAt: DateTime(2026, 5, 5),
    deliveryAddress: const DeliveryAddress(
      street: 'Rua A',
      neighborhood: 'Centro',
      city: 'Porto Alegre',
      state: 'RS',
      zipCode: '90000-000',
    ),
    bankInfo: const ProducerBankInfo(
      bank: '001',
      agency: '1234',
      account: '123456',
      pixKey: 'chave-pix@email.com',
    ),
  );

  setUp(() {
    repo = MockOrdersRepository();
    useCase = RepeatOrder(repo);
  });

  group('RepeatOrder', () {
    test('repassa orderId para o repository e retorna nova Order', () async {
      when(
        () => repo.repeatOrder(any()),
      ).thenAnswer((_) async => tOrder);

      final result = await useCase('order-1');

      expect(result.id, 'order-1');
      expect(result.farmName, 'Fazenda Teste');
      expect(result.producerId, 'p1');
      expect(result.status, OrderStatus.pending);
      verify(() => repo.repeatOrder('order-1')).called(1);
    });

    test('propaga NotFoundException quando order não existe', () async {
      when(
        () => repo.repeatOrder(any()),
      ).thenThrow(const NotFoundException());

      expect(
        () => useCase('order-nonexistent'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('propaga UnauthorizedException quando usuário não tem permissão', () async {
      when(
        () => repo.repeatOrder(any()),
      ).thenThrow(const UnauthorizedException());

      expect(
        () => useCase('order-forbidden'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('propaga NetworkException quando há erro de rede', () async {
      when(
        () => repo.repeatOrder(any()),
      ).thenThrow(const NetworkException());

      expect(
        () => useCase('order-1'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
