import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/entities/consumer_profile.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/repositories/consumer_profile_repository.dart';

@lazySingleton
class GetConsumerProfile {
  const GetConsumerProfile(this._repository);

  final ConsumerProfileRepository _repository;

  Future<ConsumerProfile> call(String userId) => _repository.getProfile(userId);
}
