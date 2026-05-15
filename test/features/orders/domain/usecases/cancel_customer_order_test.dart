import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/cancel_customer_order.dart';

class MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late CancelCustomerOrder useCase;
  late MockOrdersRepository repo;

  setUp(() {
    repo = MockOrdersRepository();
    useCase = CancelCustomerOrder(repo);
  });

  group('CancelCustomerOrder', () {
    test('repassa orderId, reason e details para o repository', () async {
      when(
        () => repo.cancelCustomerOrder(
          any(),
          reason: any(named: 'reason'),
          details: any(named: 'details'),
        ),
      ).thenAnswer((_) async {});

      await useCase('order-1', reason: 'Mudei de ideia', details: 'extra');

      verify(
        () => repo.cancelCustomerOrder(
          'order-1',
          reason: 'Mudei de ideia',
          details: 'extra',
        ),
      ).called(1);
    });

    test('omite details quando não é fornecido (passa null)', () async {
      when(
        () => repo.cancelCustomerOrder(
          any(),
          reason: any(named: 'reason'),
          details: any(named: 'details'),
        ),
      ).thenAnswer((_) async {});

      await useCase('order-2', reason: 'Outro');

      verify(
        () => repo.cancelCustomerOrder(
          'order-2',
          reason: 'Outro',
          details: null,
        ),
      ).called(1);
    });

    test('propaga NotFoundException do repository (bug C1: endpoint pode não existir)', () async {
      when(
        () => repo.cancelCustomerOrder(
          any(),
          reason: any(named: 'reason'),
          details: any(named: 'details'),
        ),
      ).thenThrow(const NotFoundException());

      expect(
        () => useCase('order-3', reason: 'Mudei de ideia'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  // Sanity-check para evitar warning de import não usado quando entidades
  // forem necessárias em testes futuros (ex.: validar tipo de retorno).
  test('entidades de orders permanecem importáveis', () {
    expect(Order, isNotNull);
    expect(OrderDetail, isNotNull);
    expect(OrderStatus.pending, isA<OrderStatus>());
  });
}
