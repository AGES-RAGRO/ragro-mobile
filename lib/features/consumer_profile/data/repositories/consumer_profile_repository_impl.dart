import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/consumer_profile/data/datasources/consumer_profile_remote_datasource.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/entities/consumer_profile.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/repositories/consumer_profile_repository.dart';

@LazySingleton(as: ConsumerProfileRepository)
class ConsumerProfileRepositoryImpl implements ConsumerProfileRepository {
  const ConsumerProfileRepositoryImpl(this._dataSource);

  final ConsumerProfileRemoteDataSource _dataSource;

  @override
  Future<ConsumerProfile> getProfile() =>
      _dataSource.getProfile();

  @override
  Future<ConsumerProfile> updateProfile({
    required String name,
    required String phone,
    required String address,
    String? fiscalNumber,
  }) =>
      _dataSource.updateProfile(
        name: name,
        phone: phone,
        address: address,
        fiscalNumber: fiscalNumber,
      );
}
