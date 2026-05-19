import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/features/home/domain/entities/favorite_producer.dart';

class FavoriteProducerModel extends FavoriteProducer {
  const FavoriteProducerModel({
    required super.producerId,
    required super.producerName,
    required super.farmName,
    required super.avatarUrl,
    required super.averageRating,
  });

  factory FavoriteProducerModel.fromJson(Map<String, dynamic> json) {
    return FavoriteProducerModel(
      producerId: json['producerId'] as String? ?? '',
      producerName: json['producerName'] as String? ?? '',
      farmName: json['farmName'] as String? ?? '',
      avatarUrl: ApiEndpoints.resolveMediaUrl(
        json['avatarUrl'] as String? ?? '',
      ),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
