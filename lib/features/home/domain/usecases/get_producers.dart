import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/paginated_response.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';
import 'package:ragro_mobile/features/home/domain/repositories/home_repository.dart';

@lazySingleton
class GetProducers {
  const GetProducers(this._repository);

  final HomeRepository _repository;

  Future<PaginatedResponse<Producer>> call({int page = 0, int size = 10}) {
    return _repository.getProducers(page: page, size: size);
  }
}
