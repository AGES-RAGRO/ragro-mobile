/// Pure resolver that maps an FCM `data` payload to an in-app route.
///
/// The backend (`FcmService.buildData`) sends a `data` map with keys:
/// `type` (the NotificationType name), `referenceType` (always "ORDER"),
/// and an optional `orderId` (uuid).
/// Kept free of Firebase/Flutter types so it is fully unit-testable.
abstract final class NotificationDeepLink {
  /// Returns the route to open for [data], or `null` when the payload has no
  /// actionable reference (caller may then just open the notifications list).
  static String? resolveRoute({
    required Map<String, dynamic> data,
    required bool isProducer,
  }) {
    final referenceType = data['referenceType']?.toString();
    final orderId = data['orderId']?.toString();

    final isOrder =
        referenceType == 'ORDER' && orderId != null && orderId.isNotEmpty;
    if (isOrder) {
      return isProducer
          ? '/producer/home/orders/$orderId'
          : '/customer/orders/$orderId';
    }
    return null;
  }
}
