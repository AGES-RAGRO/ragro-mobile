import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';

class HomeProductModel extends HomeProduct {
  const HomeProductModel({
    required super.id,
    required super.name,
    required super.category,
    required super.price,
    required super.imageUrl,
    required super.farmName,
    required super.producerId,
  });

  factory HomeProductModel.fromJson(
    Map<String, dynamic> json, {
    String fallbackFarmName = '',
  }) {
    final categories = json['categories'];
    final primaryCategory = categories is List && categories.isNotEmpty
        ? categories.first as Map<String, dynamic>
        : null;

    return HomeProductModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      category:
          json['category'] as String? ??
          primaryCategory?['name'] as String? ??
          '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: ApiEndpoints.resolveMediaUrl(
          json['imageS3'] as String? ??
          json['image_s3'] as String? ??
          json['imageUrl'] as String? ??
          ''),
      farmName:
          json['farmName'] as String? ??
          json['farm_name'] as String? ??
          fallbackFarmName,
      producerId:
          json['farmerId'] as String? ??
          json['farmer_id'] as String? ??
          json['producerId'] as String? ??
          '',
    );
  }

}
