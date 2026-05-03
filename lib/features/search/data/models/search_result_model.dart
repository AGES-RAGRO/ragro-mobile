import 'package:ragro_mobile/features/search/domain/entities/search_result.dart';

class SearchResultModel extends SearchResult {
  const SearchResultModel({
    required super.id,
    required super.type,
    required super.name,
    required super.subtitle,
    required super.imageUrl,
    super.producerId,
    super.price,
    super.rating,
    super.reviewCount,
    super.category,
    super.distance,
    super.unit,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    final type = _parseType(json['type'] as String?);
    final id = switch (type) {
      SearchResultType.product =>
        json['productId'] as String? ??
            json['product_id'] as String? ??
            json['id'] as String? ??
            '',
      SearchResultType.producer =>
        json['producerId'] as String? ??
            json['producer_id'] as String? ??
            json['id'] as String? ??
            '',
    };

    return SearchResultModel(
      id: id,
      type: type,
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      producerId:
          json['producerId'] as String? ??
          json['farmerId'] as String? ??
          json['producer_id'] as String? ??
          json['farmer_id'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int?,
      category: json['category'] as String?,
      unit: json['unit'] as String?,
    );
  }

  static SearchResultType _parseType(String? rawType) {
    return rawType == 'product'
        ? SearchResultType.product
        : SearchResultType.producer;
  }
}
