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

  // Customer cart
  static String get customerCart => '$_base/customers/carts';
  static String get customerCartItems => '$_base/customers/carts/items';
  static String customerCartItem(String id) =>
      '$_base/customers/carts/items/$id';

  // Products / Inventory
  static String get products => '$_base/products';
  static String product(String id) => '$_base/products/$id';

  // Producer inventory (authenticated as FARMER)
  static String get producerInventory => '$_base/producers/products';
  static String producerInventoryItem(String id) =>
      '$_base/producers/products/$id';
  static String producerProductPhoto(String id) =>
      '$_base/producers/products/$id/photo';
  static String get producerProductCategories =>
      '$_base/producers/products/categories';

  // Stock movements
  static String get stockExit => '$_base/producers/stock/exit';
  static String get stockEntry => '$_base/producers/stock/entry';
  static String stockProductMovements(String id) =>
      '$_base/producers/stock/$id/movements';

  // Producer management
  static String get producerDashboard => '$_base/producers/me/dashboard';

  // Routes
  static String get routesToday => '$_base/routes/today';

  // Producer orders
  static String get producerOrders => '$_base/orders/producer';
  static String get producerOrdersToday => '$_base/orders/today';
  static String producerOrderConfirm(String id) => '$_base/orders/$id/confirm';
  static String producerOrderStatus(String id) => '$_base/orders/$id/status';
  static String producerOrderCancel(String id) => '$_base/orders/$id/cancel';

  // Admin
  static String get adminProducers => '$_base/admin/producers';
  static String adminProducer(String id) => '$_base/admin/producers/$id';

  /// Rewrites a media URL that came from the backend (e.g. MinIO public URL).
  /// In dev, the backend stores `http://localhost:9000/...` but the device
  /// cannot reach `localhost` on the host machine — it needs the same host
  /// that the API uses (e.g. `10.0.2.2` for an Android emulator).
  static String resolveMediaUrl(String url) {
    if (url.isEmpty) return url;
    final mediaUri = Uri.tryParse(url);
    if (mediaUri == null) return url;
    const devHosts = {'localhost', '127.0.0.1', '10.0.2.2'};
    if (!devHosts.contains(mediaUri.host)) return url;
    final apiUri = Uri.tryParse(_base);
    if (apiUri == null) return url;
    return mediaUri.replace(host: apiUri.host).toString();
  }
}
