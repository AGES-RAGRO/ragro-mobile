import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';

abstract class AdminRepository {
  Future<List<AdminProducer>> getProducers();
  Future<void> createProducer(AdminProducer producer, String password);
  Future<void> deactivateProducer(String id);
  Future<void> activateProducer(String id);
}
