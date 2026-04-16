import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';
import 'package:ragro_mobile/features/producer_profile/domain/repositories/producer_profile_repository.dart';

@lazySingleton
class UploadProducerAvatar {
  const UploadProducerAvatar(this._repository);

  final ProducerProfileRepository _repository;

  Future<PublicProducer> call(String producerId, XFile file) =>
      _repository.uploadAvatar(producerId, file);
}

@lazySingleton
class UploadProducerCover {
  const UploadProducerCover(this._repository);

  final ProducerProfileRepository _repository;

  Future<PublicProducer> call(String producerId, XFile file) =>
      _repository.uploadCover(producerId, file);
}
