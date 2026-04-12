import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/customer_profile/domain/entities/customer_profile.dart';
import 'package:ragro_mobile/features/customer_profile/domain/repositories/customer_profile_repository.dart';

@lazySingleton
class GetCustomerProfile {
  const GetCustomerProfile(this._repository);

  final CustomerProfileRepository _repository;

  Future<CustomerProfile> call() => _repository.getProfile();
}
