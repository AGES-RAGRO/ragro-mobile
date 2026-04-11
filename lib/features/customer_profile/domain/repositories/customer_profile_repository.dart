import 'package:ragro_mobile/features/customer_profile/domain/entities/customer_profile.dart';

abstract class CustomerProfileRepository {
  Future<CustomerProfile> getProfile();

  Future<CustomerProfile> updateProfile({
    required String name,
    required String phone,
    required String street,
    required String number,
    required String city,
    required String state,
    required String zipCode,
    String? complement,
    String? neighborhood,
  });
}
