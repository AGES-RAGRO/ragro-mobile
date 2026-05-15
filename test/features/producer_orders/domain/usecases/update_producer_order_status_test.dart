import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/domain/repositories/producer_orders_repository.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/update_producer_order_status.dart';

class MockProducerOrdersRepository extends Mock
    implements ProducerOrdersRepository {}

void main() {
  late UpdateProducerOrderStatus useCase;
  late MockProducerOrdersRepository repo;

  setUpAll(() {
    registerFallbackValue(ProducerOrderStatus.pending);
  });

  setUp(() {
    repo = MockProducerOrdersRepository();
    useCase = UpdateProducerOrderStatus(repo);
  });

  group('UpdateProducerOrderStatus', () {
    test('repassa orderId e status (in_delivery) para o repository', () async {
      when(
        () => repo.updateStatus(any(), any()),
      ).thenAnswer((_) async {});

      await useCase('order-1', ProducerOrderStatus.inDelivery);

      verify(
        () => repo.updateStatus('order-1', ProducerOrderStatus.inDelivery),
      ).called(1);
    });

    test('repassa status (delivered) corretamente', () async {
      when(
        () => repo.updateStatus(any(), any()),
      ).thenAnswer((_) async {});

      await useCase('order-2', ProducerOrderStatus.delivered);

      verify(
        () => repo.updateStatus('order-2', ProducerOrderStatus.delivered),
      ).called(1);
    });

    test('propaga ForbiddenException do repository (producer sem permissão)', () async {
      when(
        () => repo.updateStatus(any(), any()),
      ).thenThrow(const ForbiddenException());

      expect(
        () => useCase('order-3', ProducerOrderStatus.delivered),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });
}
