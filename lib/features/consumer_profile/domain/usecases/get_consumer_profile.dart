import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/entities/consumer_profile.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/repositories/consumer_profile_repository.dart';

@lazySingleton
class GetCustomerProfile {
  const GetCustomerProfile(this._repository);

  final CustomerProfileRepository _repository;

  Future<CustomerProfile> call(String userId) => _repository.getProfile(userId);
}
