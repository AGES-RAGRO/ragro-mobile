abstract final class ApiEndpoints {
  static const String _defaultBase = 'http://localhost:8080';

  /// `http://10.0.2.2:8080`, device físico `http://<IP_LAN>:8080`).
  static final String _base = _resolveBaseUrl();

  static String _resolveBaseUrl() {
    const rawBase = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: _defaultBase,
    );
    final normalized = rawBase.trim().replaceFirst(RegExp(r'\/+$'), '');
    final uri = Uri.tryParse(normalized);
    final hasHttpScheme = uri?.scheme == 'http' || uri?.scheme == 'https';

    if (normalized.isEmpty || normalized == 'http:' || normalized == 'https:') {
      return _defaultBase;
    }

    if (hasHttpScheme && (uri?.host.isNotEmpty ?? false)) {
      return normalized;
    }

    return _defaultBase;
  }

  // Auth
  static String get authConfig => '$_base/auth/config';
  static String get authSession => '$_base/auth/session';
  static String get registerCustomer => '$_base/auth/register/customer';
  static String get resetPasswordEmail => '$_base/auth/password/reset';
  static String get forgotPassword => '$_base/auth/password/forgot';

  // Customers
  static String get customers => '$_base/customers';
  static String get customerMe => '$_base/customers/me';

  // Producers / Farmers
  static String get producers => '$_base/producers';
  static String get search => '$_base/search';
  static String get recommendations => '$_base/recommendations';
  static String producer(String id) => '$_base/producers/$id';
  static String producerPublicProfile(String id) =>
      '$_base/producers/$id/profile';
  static String producerProducts(String id) => '$_base/producers/$id/products';
  static String producerProduct(String producerId, String productId) =>
      '$_base/producers/$producerId/products/$productId';
  static String producerAvatar(String id) => '$_base/producers/$id/avatar';
  static String producerCover(String id) => '$_base/producers/$id/cover';

  // Orders
  static String get orders => '$_base/orders';
  static String order(String id) => '$_base/orders/$id';
  static String orderRating(String id) => '$_base/orders/$id/rating';

  // Cart (local, no API endpoints needed yet)

  // Products / Inventory
  static String get products => '$_base/products';
  static String product(String id) => '$_base/products/$id';

  // Producer management
  static String get producerDashboard => '$_base/producers/me/dashboard';

  // Producer orders
  static String get producerOrders => '$_base/orders/producer';
  static String get producerOrdersToday => '$_base/orders/today';
  static String producerOrderConfirm(String id) => '$_base/orders/$id/confirm';
  static String producerOrderStatus(String id) => '$_base/orders/$id/status';
  static String producerOrderCancel(String id) => '$_base/orders/$id/cancel';

  // Admin
  static String get adminProducers => '$_base/admin/producers';
  static String adminProducer(String id) => '$_base/admin/producers/$id';
}
