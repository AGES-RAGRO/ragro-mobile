// lib/core/network/api_endpoints.dart
abstract final class ApiEndpoints {
  static const String _base = 'https://api.ragro.com.br';

  // Auth
  static const String loginConsumer = '$_base/auth/login/consumer';
  static const String loginProducer = '$_base/auth/login/producer';
  static const String loginAdmin    = '$_base/auth/login/admin';
  static const String registerConsumer = '$_base/auth/register/consumer';

  // Consumers
  static String consumer(String id)   => '$_base/consumers/$id';

  // Producers / Farmers
  static const String producers       = '$_base/producers';
  static String producer(String id)   => '$_base/producers/$id';

  // Admin
  static const String adminProducers  = '$_base/admin/producers';
  static String adminProducer(String id) => '$_base/admin/producers/$id';
}
