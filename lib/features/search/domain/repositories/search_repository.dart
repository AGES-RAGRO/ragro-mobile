import 'package:ragro_mobile/features/search/domain/entities/search_result.dart';

abstract class SearchRepository {
  Future<List<SearchResult>> search({
    required String query,
    String? category,
  });
}
