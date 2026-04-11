import 'package:ragro_mobile/features/home/data/models/home_product_model.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';

class PublicProducerModel extends PublicProducer {
  const PublicProducerModel({
    required super.id,
    required super.name,
    required super.farmName,
    required super.location,
    required super.description,
    required super.story,
    required super.avatarUrl,
    required super.coverUrl,
    required super.averageRating,
    required super.totalReviews,
    required super.totalOrders,
    required super.phone,
    required super.products,
    required super.availability,
    required super.memberSince,
  });

  factory PublicProducerModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    return PublicProducerModel(
      id: json['id'] as String,
      name: user['name'] as String? ?? '',
      farmName: json['farm_name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      story: json['story'] as String? ?? '',
      avatarUrl: json['avatar_s3'] as String? ?? '',
      coverUrl: json['display_photo_s3'] as String? ?? '',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
      phone: user['phone'] as String? ?? '',
      products:
          ((json['products'] as List?)?.map(
                    (p) => HomeProductModel.fromJson(p as Map<String, dynamic>),
                  ) ??
                  [])
              .toList(),
      availability:
          ((json['availability'] as List?)?.map(
                    (a) => AvailabilitySlot(
                      weekday: a['weekday'] as int,
                      opensAt: a['opens_at'] as String,
                      closesAt: a['closes_at'] as String,
                    ),
                  ) ??
                  [])
              .toList(),
      memberSince: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime(2016),
    );
  }

  static PublicProducerModel mock(String id) {
    return PublicProducerModel(
      id: id,
      name: 'João Nascimento',
      farmName: 'Fazenda Sol Nascente',
      location: 'Mato Grosso, Brasil',
      description: '"Orgânicos colhidos no dia para mesa da sua família"',
      story:
          '"Dedicados à agricultura regenerativa e ao respeito à terra há três gerações. Nosso compromisso é cultivar alimentos saudáveis preservando a biodiversidade do nosso cerrado."',
      avatarUrl: '',
      coverUrl: '',
      averageRating: 4.9,
      totalReviews: 234,
      totalOrders: 1200,
      phone: '+55 (65) 99999-0000',
      products: HomeProductModel.mocks(),
      availability: const [
        AvailabilitySlot(weekday: 1, opensAt: '14:00', closesAt: '18:30'),
        AvailabilitySlot(weekday: 2, opensAt: '14:00', closesAt: '18:30'),
        AvailabilitySlot(weekday: 3, opensAt: '14:00', closesAt: '18:30'),
        AvailabilitySlot(weekday: 4, opensAt: '14:00', closesAt: '18:30'),
        AvailabilitySlot(weekday: 5, opensAt: '14:00', closesAt: '18:30'),
        AvailabilitySlot(weekday: 6, opensAt: '14:00', closesAt: '18:30'),
      ],
      memberSince: DateTime(2017, 3, 1),
    );
  }
}
