import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_management/data/datasources/producer_management_remote_datasource.dart';
import 'package:ragro_mobile/features/producer_management/domain/entities/producer_dashboard.dart';
import 'package:ragro_mobile/features/producer_management/domain/repositories/producer_management_repository.dart';

@LazySingleton(as: ProducerManagementRepository)
class ProducerManagementRepositoryImpl implements ProducerManagementRepository {
  const ProducerManagementRepositoryImpl(this._dataSource);

  final ProducerManagementRemoteDataSource _dataSource;

  @override
  Future<ProducerDashboard> getDashboard() => _dataSource.getDashboard();
}
