import 'package:ragro_mobile/features/producer_management/domain/entities/producer_dashboard.dart';

abstract class ProducerManagementRepository {
  Future<ProducerDashboard> getDashboard();
}
