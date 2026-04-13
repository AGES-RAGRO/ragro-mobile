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
  Future<void> updateProducer({
    required String producerId,
    required String name,
    required String story,
    required String phone,

    required String farmName,
  }) {
    final request = ProducerUpdateRequest(
      name: name.trim(),
      story: story.trim(),
      phone: phone.trim(),
      farmName: farmName.trim(),
    );
    return _dataSource.updateProducer(producerId, request);
  }
}
