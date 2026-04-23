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
    super.reviewCount,
    super.category,
    super.distance,
    super.unit,
  });

  // static List<SearchResultModel> mocks(String query) {
  //   return [
  //     const SearchResultModel(
  //       id: 'p1',
  //       type: SearchResultType.product,
  //       name: 'Tomate Cereja Orgânico',
  //       subtitle: 'Fazenda Sol Nascente',
  //       imageUrl: '',
  //       price: 12.90,
  //       unit: 'kg',
  //       category: 'Horta',
  //     ),
  //     const SearchResultModel(
  //       id: 'p2',
  //       type: SearchResultType.product,
  //       name: 'Alface Crespa',
  //       subtitle: 'Fazenda Sol Nascente',
  //       imageUrl: '',
  //       price: 3.50,
  //       unit: 'un',
  //       category: 'Horta',
  //     ),
  //     const SearchResultModel(
  //       id: 'pr1',
  //       type: SearchResultType.producer,
  //       name: 'Fazenda Sol Nascente',
  //       subtitle: 'Caxias do Sul, RS • 4.9 ★',
  //       imageUrl: '',
  //       rating: 4.9,
  //     ),
  //   ];
  // }

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] as String,
      type: SearchResultType.producer,
      name: json['farmName'] as String? ?? json['farm_name'] as String? ?? '',
      subtitle:
          json['userName'] as String? ?? json['user']?['name'] as String? ?? '',
      imageUrl:
          json['avatarS3'] as String? ?? json['avatar_s3'] as String? ?? '',
      rating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: json['totalReviews'] as int?,
      price: null,
      category: null,
      distance: null,
      unit: null,
    );
  }
}
