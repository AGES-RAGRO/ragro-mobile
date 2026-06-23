import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/features/notifications/domain/notification_deep_link.dart';

void main() {
  group('NotificationDeepLink.resolveRoute', () {
    test('customer order → /customer/orders/<id>', () {
      final route = NotificationDeepLink.resolveRoute(
        data: const {
          'type': 'ORDER_CONFIRMED',
          'referenceType': 'ORDER',
          'orderId': 'abc-123',
        },
        isProducer: false,
      );
      expect(route, '/customer/orders/abc-123');
    });

    test('producer order → /producer/home/orders/<id>', () {
      final route = NotificationDeepLink.resolveRoute(
        data: const {
          'type': 'NEW_ORDER',
          'referenceType': 'ORDER',
          'orderId': 'xyz-9',
        },
        isProducer: true,
      );
      expect(route, '/producer/home/orders/xyz-9');
    });

    test('missing orderId → null', () {
      final route = NotificationDeepLink.resolveRoute(
        data: const {'type': 'ORDER_CONFIRMED', 'referenceType': 'ORDER'},
        isProducer: false,
      );
      expect(route, isNull);
    });

    test('non-order referenceType → null', () {
      final route = NotificationDeepLink.resolveRoute(
        data: const {'referenceType': 'OTHER', 'orderId': 'abc'},
        isProducer: true,
      );
      expect(route, isNull);
    });

    test('empty data → null', () {
      final route = NotificationDeepLink.resolveRoute(
        data: const {},
        isProducer: false,
      );
      expect(route, isNull);
    });
  });
}
