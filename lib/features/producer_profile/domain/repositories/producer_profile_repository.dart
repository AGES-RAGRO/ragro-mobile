import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';

abstract class ProducerProfileRepository {
  Future<PublicProducer> getProducer(String producerId);
}
