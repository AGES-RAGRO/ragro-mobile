import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/search/data/datasources/search_remote_datasource.dart';
import 'package:ragro_mobile/features/search/domain/entities/search_result.dart';
import 'package:ragro_mobile/features/search/domain/repositories/search_repository.dart';

@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl(this._dataSource);

  final SearchRemoteDataSource _dataSource;

  @override
  Future<List<SearchResult>> search({
    required String query,
    String? category,
  }) async {
    final list = await _dataSource.search(query: query, category: category);
    return List<SearchResult>.from(list);
  }

  @override
  Future<List<SearchResult>> getProductsByCategory({required String category}) async {
    final list = await _dataSource.getProductsByCategory(category: category);
    return List<SearchResult>.from(list);
  }
}
