import 'package:ragro_mobile/features/home/domain/entities/producer.dart';

class ProducerModel extends Producer {
  const ProducerModel({
    required super.id,
    required super.name,
    required super.description,
    required super.avatarUrl,
    required super.averageRating,
    required super.ownerName,
  });

  factory ProducerModel.fromJson(Map<String, dynamic> json) {
    return ProducerModel(
      id: (json['id'] ?? '').toString(),
      name: json['farm_name'] as String? ?? 'Fazenda sem nome',
      description: json['description'] as String? ?? '',
      avatarUrl:
          json['avatar_s3'] as String? ?? json['avatarUrl'] as String? ?? '',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      ownerName: json['owner_name'] as String? ?? '',
    );
  }

  static ProducerModel mock(int index) {
    return ProducerModel(
      id: 'producer_$index',
      name: 'Fazenda Sol Nascente',
      description: '"Orgânicos colhidos no dia para...',
      avatarUrl: '',
      averageRating: 4.9,
      ownerName: 'Sr. Manoel Silva',
    );
  }
}
