import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_profile/domain/repositories/producer_profile_repository.dart';

@lazySingleton
class UpdateProducer {
  const UpdateProducer(this._repository);

  final ProducerProfileRepository _repository;

  Future<void> call({
    required String producerId,
    required String name,
    required String story,
    required String phone,
    required String farmName,
  }) => _repository.updateProducer(
    producerId: producerId,
    name: name,
    story: story,
    phone: phone,
    farmName: farmName,
  );
}
