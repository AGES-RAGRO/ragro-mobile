import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/entities/consumer_profile.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/repositories/consumer_profile_repository.dart';

@lazySingleton
class UpdateConsumerProfile {
  const UpdateConsumerProfile(this._repository);

  final ConsumerProfileRepository _repository;

  Future<ConsumerProfile> call({
    required String name,
    required String phone,
    required String address,
    String? fiscalNumber,
  }) =>
      _repository.updateProfile(
        name: name,
        phone: phone,
        address: address,
        fiscalNumber: fiscalNumber,
      );
}
