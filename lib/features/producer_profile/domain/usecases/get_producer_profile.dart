import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';
import 'package:ragro_mobile/features/producer_profile/domain/repositories/producer_profile_repository.dart';

@lazySingleton
class GetProducerProfile {
  const GetProducerProfile(this._repository);

  final ProducerProfileRepository _repository;

  Future<PublicProducer> call(String producerId) => _repository.getProducer(producerId);
}
