import 'package:ragro_mobile/features/home/data/models/home_product_model.dart';
import 'package:ragro_mobile/features/producer_profile/data/models/review_model.dart';
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
    super.fiscalNumber,
    super.producerAddress,
    super.paymentMethods,
    super.reviews,
  });

  factory PublicProducerModel.mock(String id) {
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
      memberSince: DateTime(2017, 3),
      reviews: [
        ReviewModel(
          id: '1',
          authorName: 'Maria Silva',
          rating: 5.0,
          comment: 'Produtos frescos e de excelente qualidade! Recomendo!',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          authorAvatarUrl: null,
        ),
        ReviewModel(
          id: '2',
          authorName: 'Pedro Oliveira',
          rating: 4.5,
          comment: 'Ótimo atendimento e produtos bem embalados.',
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          authorAvatarUrl: null,
        ),
        ReviewModel(
          id: '3',
          authorName: 'Ana Costa',
          rating: 5.0,
          comment: 'Entrega rápida e produtos no ponto!',
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          authorAvatarUrl: null,
        ),
      ],
    );
  }

  factory PublicProducerModel.fromJson(Map<String, dynamic> json) {
    // Alinhado com ProducerGetResponse do backend (EPIC 1 — Jackson camelCase).
    // Dual-parse mantém fallback snake_case para payloads legados/mocks.
    // products e availability NÃO vêm neste endpoint — virão de queries separadas
    // (GET /products?producerId=..., e endpoint de availability quando exposto).
    final address = json['address'] as Map<String, dynamic>?;
    final location = _deriveLocation(json, address);

    ProducerAddress? producerAddress;
    if (address != null) {
      producerAddress = ProducerAddress(
        street: address['street'] as String? ?? '',
        number: address['number'] as String? ?? '',
        city: address['city'] as String? ?? '',
        state: address['state'] as String? ?? '',
        zipCode: address['zipCode'] as String? ?? '',
        complement: address['complement'] as String?,
        neighborhood: address['neighborhood'] as String?,
        latitude: (address['latitude'] as num?)?.toDouble(),
        longitude: (address['longitude'] as num?)?.toDouble(),
      );
    }

    final memberSinceRaw =
        json['memberSince'] as String? ?? json['created_at'] as String?;

    return PublicProducerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      farmName:
          json['farmName'] as String? ?? json['farm_name'] as String? ?? '',
      location: location,
      description: json['description'] as String? ?? '',
      story: json['story'] as String? ?? '',
      avatarUrl:
          json['avatarS3'] as String? ?? json['avatar_s3'] as String? ?? '',
      coverUrl:
          json['displayPhotoS3'] as String? ??
          json['display_photo_s3'] as String? ??
          '',
      averageRating:
          (json['averageRating'] as num?)?.toDouble() ??
          (json['average_rating'] as num?)?.toDouble() ??
          0.0,
      totalReviews:
          json['totalReviews'] as int? ?? json['total_reviews'] as int? ?? 0,
      totalOrders:
          json['totalOrders'] as int? ?? json['total_orders'] as int? ?? 0,
      phone: json['phone'] as String? ?? '',
      products: _parseProducts(json['products']),
      availability: _parseAvailability(json['availability']),
      reviews: _parseReviews(json['reviews']),
      memberSince: memberSinceRaw != null
          ? DateTime.parse(memberSinceRaw)
          : DateTime(2016),
      fiscalNumber: json['fiscalNumber'] as String?,
      producerAddress: producerAddress,
      paymentMethods: _parsePaymentMethods(json['paymentMethods']),
    );
  }

  static String _deriveLocation(
    Map<String, dynamic> json,
    Map<String, dynamic>? address,
  ) {
    if (address != null) {
      final city = (address['city'] as String?)?.trim() ?? '';
      final state = (address['state'] as String?)?.trim() ?? '';
      if (city.isNotEmpty && state.isNotEmpty) return '$city, $state';
      if (city.isNotEmpty) return city;
      if (state.isNotEmpty) return state;
    }
    return (json['location'] as String?) ?? '';
  }

  static List<HomeProductModel> _parseProducts(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((p) => HomeProductModel.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  static List<AvailabilitySlot> _parseAvailability(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((a) {
      final slot = a as Map<String, dynamic>;
      return AvailabilitySlot(
        weekday: slot['weekday'] as int,
        opensAt:
            slot['opensAt'] as String? ?? slot['opens_at'] as String? ?? '',
        closesAt:
            slot['closesAt'] as String? ?? slot['closes_at'] as String? ?? '',
      );
    }).toList();
  }

  static List<ProducerPaymentMethod>? _parsePaymentMethods(dynamic raw) {
    if (raw is! List) return null;
    return raw.map((pm) {
      final json = pm as Map<String, dynamic>;
      return ProducerPaymentMethod(
        type: json['type'] as String? ?? '',
        pixKeyType: json['pixKeyType'] as String?,
        pixKey: json['pixKey'] as String?,
        bankCode: json['bankCode'] as String?,
        bankName: json['bankName'] as String?,
        agency: json['agency'] as String?,
        accountNumber: json['accountNumber'] as String?,
        accountType: json['accountType'] as String?,
        holderName: json['holderName'] as String?,
        fiscalNumber: json['fiscalNumber'] as String?,
      );
    }).toList();
  }

  static List<ReviewModel> _parseReviews(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((r) => ReviewModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
