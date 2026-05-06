import 'package:image_picker/image_picker.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';

abstract class ProducerProfileRepository {
  Future<PublicProducer> getProducer(String producerId);

  Future<PublicProducer> getOwnProfile(String producerId);

  Future<void> updateProducer({
    required String producerId,
    required String name,
    required String description,
    required String phone,
    required String farmName,
    Map<String, dynamic>? address,
    List<Map<String, dynamic>>? paymentMethods,
    List<Map<String, dynamic>>? availability,
  });

  Future<PublicProducer> uploadAvatar(String producerId, XFile file);

  Future<PublicProducer> uploadCover(String producerId, XFile file);
}
