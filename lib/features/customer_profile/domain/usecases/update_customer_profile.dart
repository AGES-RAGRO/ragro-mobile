import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/customer_profile/domain/entities/customer_profile.dart';
import 'package:ragro_mobile/features/customer_profile/domain/repositories/customer_profile_repository.dart';

@lazySingleton
class UpdateCustomerProfile {
  const UpdateCustomerProfile(this._repository);

  final CustomerProfileRepository _repository;

  Future<CustomerProfile> call({
    required String name,
    required String phone,
    required String street,
    required String number,
    required String city,
    required String state,
    required String zipCode,
    String? complement,
    String? neighborhood,
  }) => _repository.updateProfile(
    name: name,
    phone: phone,
    street: street,
    number: number,
    city: city,
    state: state,
    zipCode: zipCode,
    complement: complement,
    neighborhood: neighborhood,
  );
}
