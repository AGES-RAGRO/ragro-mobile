import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/features/producer_orders/data/models/producer_order_model.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

void main() {
  group('ProducerOrderModel.fromJson', () {
    Map<String, dynamic> baseJson() => <String, dynamic>{
      'id': 'order-1',
      'status': 'PENDING',
      'isNew': false,
      'items': <dynamic>[],
    };

    test('cancellationReason: respeita a ordem de fallback das chaves', () {
      expect(
        ProducerOrderModel.fromJson(
          baseJson()..['cancellationReason'] = 'A',
        ).cancellationReason,
        'A',
      );
      expect(
        ProducerOrderModel.fromJson(
          baseJson()..['cancelReason'] = 'B',
        ).cancellationReason,
        'B',
      );
      expect(
        ProducerOrderModel.fromJson(
          baseJson()..['reason'] = 'C',
        ).cancellationReason,
        'C',
      );
    });

    test('cancellationDetails: respeita a ordem de fallback das chaves', () {
      expect(
        ProducerOrderModel.fromJson(
          baseJson()..['cancellationDetails'] = 'A',
        ).cancellationDetails,
        'A',
      );
      expect(
        ProducerOrderModel.fromJson(
          baseJson()..['cancelDetails'] = 'B',
        ).cancellationDetails,
        'B',
      );
      expect(
        ProducerOrderModel.fromJson(
          baseJson()..['details'] = 'C',
        ).cancellationDetails,
        'C',
      );
    });

    test('cancellationReason/Details são null quando ausentes '
        '(contrato atual do backend para a lista do produtor)', () {
      final model = ProducerOrderModel.fromJson(baseJson());
      expect(model.cancellationReason, isNull);
      expect(model.cancellationDetails, isNull);
    });

    test('mapeia status do backend para o enum', () {
      expect(
        ProducerOrderModel.fromJson(
          baseJson()..['status'] = 'CANCELLED',
        ).status,
        ProducerOrderStatus.cancelled,
      );
      expect(
        ProducerOrderModel.fromJson(
          baseJson()..['status'] = 'CONFIRMED',
        ).status,
        ProducerOrderStatus.accepted,
      );
      expect(
        ProducerOrderModel.fromJson(
          baseJson()..['status'] = 'DESCONHECIDO',
        ).status,
        ProducerOrderStatus.pending,
      );
    });

    test('resolve nome do cliente pelas chaves alternativas', () {
      expect(
        ProducerOrderModel.fromJson(
          baseJson()..['customerName'] = 'Maria',
        ).consumerName,
        'Maria',
      );
      expect(
        ProducerOrderModel.fromJson(
          baseJson()..['consumer'] = {'name': 'João'},
        ).consumerName,
        'João',
      );
    });
  });
}
