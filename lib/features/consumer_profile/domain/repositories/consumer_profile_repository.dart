import 'package:ragro_mobile/features/consumer_profile/domain/entities/consumer_profile.dart';

abstract class ConsumerProfileRepository {
  Future<ConsumerProfile> getProfile();
  Future<ConsumerProfile> updateProfile({
    required String name,
    required String phone,
    required String address,
    String? fiscalNumber,
  });
}
