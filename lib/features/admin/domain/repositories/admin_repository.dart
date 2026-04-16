import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer_summary.dart';

abstract class AdminRepository {
  Future<List<AdminProducerSummary>> getProducers();
  Future<AdminProducer> getProducerById(String id);
  Future<void> createProducer(AdminProducer producer, String password);
  Future<void> updateProducer(AdminProducer producer);
  Future<void> deactivateProducer(String id);
  Future<void> activateProducer(String id);
}
