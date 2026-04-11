// lib/core/network/api_endpoints.dart
abstract final class ApiEndpoints {
  /// `http://10.0.2.2:8080`, device físico `http://<IP_LAN>:8080`).
  static const String _base = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  // Auth
  static const String authConfig = '$_base/auth/config';
  static const String authSession = '$_base/auth/session';
  static const String registerCustomer = '$_base/auth/register/customer';

  // Consumers
  static const String consumers = '$_base/consumers';
  static String consumer(String id) => '$_base/consumers/$id';

  // Producers / Farmers
  static const String producers = '$_base/producers';
  static const String recommendations = '$_base/recommendations';
  static String producer(String id) => '$_base/producers/$id';

  // Orders
  static const String orders = '$_base/orders';
  static String order(String id) => '$_base/orders/$id';
  static String orderRating(String id) => '$_base/orders/$id/rating';

  // Cart (local, no API endpoints needed yet)

  // Products / Inventory
  static const String products = '$_base/products';
  static String product(String id) => '$_base/products/$id';

  // Producer management
  static const String producerDashboard = '$_base/producers/me/dashboard';

  // Producer orders
  static const String producerOrders = '$_base/orders/producer';
  static const String producerOrdersToday = '$_base/orders/today';
  static String producerOrderConfirm(String id) => '$_base/orders/$id/confirm';
  static String producerOrderStatus(String id) => '$_base/orders/$id/status';
  static String producerOrderCancel(String id) => '$_base/orders/$id/cancel';

  // Admin
  static const String adminProducers = '$_base/admin/producers';
  static String adminProducer(String id) => '$_base/admin/producers/$id';
}
