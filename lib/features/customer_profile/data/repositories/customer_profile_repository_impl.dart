import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/customer_profile/data/datasources/customer_profile_remote_datasource.dart';
import 'package:ragro_mobile/features/customer_profile/domain/entities/customer_profile.dart';
import 'package:ragro_mobile/features/customer_profile/domain/repositories/customer_profile_repository.dart';

@LazySingleton(as: CustomerProfileRepository)
class CustomerProfileRepositoryImpl implements CustomerProfileRepository {
  const CustomerProfileRepositoryImpl(this._dataSource);

  final CustomerProfileRemoteDataSource _dataSource;

  @override
  Future<CustomerProfile> getProfile() => _dataSource.getProfile();

  @override
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
  }) => _dataSource.updateProfile(
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
