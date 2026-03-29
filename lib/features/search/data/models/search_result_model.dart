import 'package:ragro_mobile/features/search/domain/entities/search_result.dart';

class SearchResultModel extends SearchResult {
  const SearchResultModel({
    required super.id,
    required super.type,
    required super.name,
    required super.subtitle,
    required super.imageUrl,
    super.price,
    super.rating,
    super.category,
  });

  static List<SearchResultModel> mocks(String query) {
    return [
      const SearchResultModel(
        id: 'p1',
        type: SearchResultType.product,
        name: 'Tomate Cereja Orgânico',
        subtitle: 'Fazenda Sol Nascente',
        imageUrl: '',
        price: 12.90,
        category: 'Horta',
      ),
      const SearchResultModel(
        id: 'p2',
        type: SearchResultType.product,
        name: 'Alface Crespa',
        subtitle: 'Fazenda Sol Nascente',
        imageUrl: '',
        price: 3.50,
        category: 'Horta',
      ),
      const SearchResultModel(
        id: 'pr1',
        type: SearchResultType.producer,
        name: 'Fazenda Sol Nascente',
        subtitle: 'Caxias do Sul, RS • 4.9 ★',
        imageUrl: '',
        rating: 4.9,
      ),
    ];
  }
}
