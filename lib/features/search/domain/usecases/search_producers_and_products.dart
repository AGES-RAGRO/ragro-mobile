import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/search/domain/entities/search_result.dart';
import 'package:ragro_mobile/features/search/domain/repositories/search_repository.dart';

@lazySingleton
class SearchProducersAndProducts {
  const SearchProducersAndProducts(this._repository);

  final SearchRepository _repository;

  Future<List<SearchResult>> call({required String query, String? category}) =>
      _repository.search(query: query, category: category);
}
