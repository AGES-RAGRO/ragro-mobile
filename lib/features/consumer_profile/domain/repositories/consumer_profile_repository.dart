import 'package:ragro_mobile/features/consumer_profile/domain/entities/consumer_profile.dart';

abstract class CustomerProfileRepository {
  Future<CustomerProfile> getProfile(String userId);
  Future<CustomerProfile> updateProfile({
    required String userId,
    required String name,
    required String phone,
    required String address,
    String? fiscalNumber,
  });
}
