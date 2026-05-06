import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/confirm_order.dart';

class MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late ConfirmOrder useCase;
  late MockOrdersRepository repo;

  final tOrder = Order(
    id: 'order-new-1',
    producerId: 'p1',
    producerPhone: '5199999999',
    farmName: 'Fazenda Teste',
    farmAvatarUrl: 'http://example.com/avatar.jpg',
    ownerName: 'Maria Silva',
    items: const [],
    totalAmount: 200.0,
    status: OrderStatus.pending,
    createdAt: DateTime(2026, 5, 5),
    deliveryAddress: const DeliveryAddress(
      street: 'Rua B',
      neighborhood: 'Bom Fim',
      city: 'Porto Alegre',
      state: 'RS',
      zipCode: '90000-000',
    ),
    bankInfo: const ProducerBankInfo(
      bank: '001',
      agency: '1234',
      account: '123456',
      pixKey: 'chave-pix@example.com',
    ),
  );

  setUp(() {
    repo = MockOrdersRepository();
    useCase = ConfirmOrder(repo);
  });

  group('ConfirmOrder', () {
    test('chama createOrderFromCart e retorna nova Order', () async {
      when(
        () => repo.createOrderFromCart(),
      ).thenAnswer((_) async => tOrder);

      final result = await useCase();

      expect(result.id, 'order-new-1');
      expect(result.status, OrderStatus.pending);
      expect(result.farmName, 'Fazenda Teste');
      verify(() => repo.createOrderFromCart()).called(1);
    });

    test('ignora cartId quando fornecido (parâmetro opcional não usado)', () async {
      when(
        () => repo.createOrderFromCart(),
      ).thenAnswer((_) async => tOrder);

      final result = await useCase('cart-123');

      expect(result.id, 'order-new-1');
      verify(() => repo.createOrderFromCart()).called(1);
    });

    test('propaga ConflictException quando carrinho vazio ou inválido', () async {
      when(
        () => repo.createOrderFromCart(),
      ).thenThrow(const ConflictException());

      expect(
        () => useCase(),
        throwsA(isA<ConflictException>()),
      );
    });

    test('propaga UnauthorizedException quando usuário não autenticado', () async {
      when(
        () => repo.createOrderFromCart(),
      ).thenThrow(const UnauthorizedException());

      expect(
        () => useCase(),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('propaga ServerException em erro do servidor', () async {
      when(
        () => repo.createOrderFromCart(),
      ).thenThrow(const ServerException());

      expect(
        () => useCase(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
