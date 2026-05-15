import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_profile/data/datasources/producer_profile_remote_datasource.dart';
import 'package:ragro_mobile/features/producer_profile/data/models/producer_update_request.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';
import 'package:ragro_mobile/features/producer_profile/domain/repositories/producer_profile_repository.dart';

@LazySingleton(as: ProducerProfileRepository)
class ProducerProfileRepositoryImpl implements ProducerProfileRepository {
  const ProducerProfileRepositoryImpl(this._dataSource);

  final ProducerProfileRemoteDataSource _dataSource;

  @override
  Future<PublicProducer> getProducer(String producerId) =>
      _dataSource.getProducer(producerId);

  @override
  Future<PublicProducer> getOwnProfile(String producerId) =>
      _dataSource.getOwnProfile(producerId);

  @override
  Future<void> updateProducer({
    required String producerId,
    required String name,
    required String description,
    required String phone,
    required String farmName,
    Map<String, dynamic>? address,
    List<Map<String, dynamic>>? paymentMethods,
    List<Map<String, dynamic>>? availability,
  }) {
    final request = ProducerUpdateRequest(
      name: name.trim(),
      phone: phone.trim(),
      farmName: farmName.trim(),
      description: description.trim(),
      address: address,
      paymentMethods: paymentMethods,
      availability: availability,
    );
    return _dataSource.updateProducer(producerId, request);
  }

  @override
  Future<PublicProducer> uploadAvatar(String producerId, XFile file) =>
      _dataSource.uploadAvatar(producerId, file);

  @override
  Future<PublicProducer> uploadCover(String producerId, XFile file) =>
      _dataSource.uploadCover(producerId, file);
}
