import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/entities/consumer_profile.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/repositories/consumer_profile_repository.dart';

@lazySingleton
class UpdateCustomerProfile {
  const UpdateCustomerProfile(this._repository);

  final CustomerProfileRepository _repository;

  Future<CustomerProfile> call({
    required String userId,
    required String name,
    required String phone,
    required String address,
    String? fiscalNumber,
  }) =>
      _repository.updateProfile(
        userId: userId,
        name: name,
        phone: phone,
        address: address,
        fiscalNumber: fiscalNumber,
      );
}
