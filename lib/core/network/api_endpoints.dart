import 'dart:io';
import 'package:flutter/foundation.dart';

abstract final class ApiEndpoints {
  // Default for local dev. In prod, pass --dart-define-from-file=env/prod.json
  // (or --dart-define=API_BASE_URL=https://...) via CI.
  static const String _localBase = 'http://localhost:8080';

  static final String _base = _resolveBaseUrl();

  static String _resolveBaseUrl() {
    const rawBase = String.fromEnvironment('API_BASE_URL');

    if (rawBase.trim().isNotEmpty) {
      final normalized = rawBase.trim().replaceFirst(RegExp(r'\/+$'), '');
      return _normalizeForRuntime(normalized);
    }

    return _normalizeForRuntime(_localBase);
  }

  /// Fixes URLs that come from the backend (like Keycloak token URLs)
  /// to be reachable from the emulator.
  static String fixUrl(String url) {
    return _normalizeForRuntime(url);
  }

  static String _normalizeForRuntime(String url) {
    if (url.isEmpty) return url;
    if (kIsWeb) return url;

    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    if (Platform.isAndroid &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
      return uri.replace(host: '10.0.2.2').toString();
    }

    return url;
  }

  // Auth
  static String get authConfig => '$_base/auth/config';
  static String get authSession => '$_base/auth/session';
  static String get registerCustomer => '$_base/auth/register/customer';
  static String get resetPasswordEmail => '$_base/auth/password/reset';
  static String get forgotPassword => '$_base/auth/password/forgot';

  /// Public endpoints that must never carry an `Authorization` header.
  static const Set<String> _publicPathSuffixes = {
    '/auth/register/customer',
    '/auth/password/forgot',
    '/auth/config',
  };

  static bool isPublic(String path) => _publicPathSuffixes.any(path.endsWith);

  // Customers
  static String get customers => '$_base/customers';
  static String get customerMe => '$_base/customers/me';
  static String get customerFavorites => '$_base/customers/me/favorites';
  static String customerFavorite(String producerId) =>
      '$_base/customers/me/favorites/$producerId';

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
  static String producerReviews(String id) => '$_base/producers/$id/reviews';
  static String get co2TotalSaved => '$_base/co2/total-saved';
  static String get co2Calculate => '$_base/co2/calculate';
  static String get co2RecordSavings => '$_base/co2/record-savings';
  static String get co2Options => '$_base/co2/options';

  // Routes (optimized via backend; the Google key stays on the server)
  static String get routesOptimize => '$_base/routes/optimize';

  // Orders
  static String get orders => '$_base/orders';
  static String get consumerOrders => '$_base/orders/consumer';
  static String order(String id) => '$_base/orders/$id';
  static String customerOrder(String id) => '$_base/orders/customer/$id';
  static String customerOrderCancel(String id) =>
      '$_base/orders/customer/$id/cancel';
  static String customerOrderConfirmDelivery(String id) =>
      '$_base/orders/customer/$id/confirm-delivery';
  static String orderCancel(String id) => '$_base/orders/$id/cancel';
  static String orderStatus(String id) => '$_base/orders/$id/status';
  static String orderConfirm(String id) => '$_base/orders/$id/confirm';
  static String orderSeen(String id) => '$_base/orders/$id/seen';
  static String get reviews => '$_base/reviews';

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
  static String get producerDashboardWeek =>
      '$_base/producers/me/dashboard/week';

  // Producer orders
  static String get producerOrders => '$_base/orders/producer';
  static String producerOrderConfirm(String id) => orderConfirm(id);
  static String producerOrderStatus(String id) => orderStatus(id);
  static String producerOrderCancel(String id) => orderCancel(id);

  // Admin
  static String get adminProducers => '$_base/admin/producers';
  static String adminProducer(String id) => '$_base/admin/producers/$id';

  /// Rewrites a media URL that came from the backend (e.g. MinIO public URL).
  /// This keeps local backend URLs reachable on emulators by matching the
  /// host used by the configured API base URL.
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
