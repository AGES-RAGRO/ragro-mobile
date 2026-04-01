import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/repositories/admin_repository.dart';

@LazySingleton(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._dataSource);

  final AdminRemoteDataSource _dataSource;

  @override
  Future<List<AdminProducer>> getProducers() =>
      _dataSource.getProducers();

  @override
  Future<void> createProducer(AdminProducer producer, String password) =>
      _dataSource.createProducer(producer, password);

  @override
  Future<void> deactivateProducer(String id) =>
      _dataSource.deactivateProducer(id);

  @override
  Future<void> activateProducer(String id) =>
      _dataSource.activateProducer(id);
}
