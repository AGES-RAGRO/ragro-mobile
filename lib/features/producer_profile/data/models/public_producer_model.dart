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
    required super.phone,
    required super.availability,
    required super.memberSince,
    super.photoUrl,
    super.producerAddress,
  });

  /// Parses ProducerPublicProfileResponse from backend
  /// Aligns with: GET /producers/{id}/profile
  /// @PreAuthorize("hasRole('CUSTOMER')")
  factory PublicProducerModel.fromJson(Map<String, dynamic> json) {
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

    final memberSinceRaw = json['memberSince'] as String?;

    return PublicProducerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      farmName: json['farmName'] as String? ?? '',
      location: location,
      description: json['description'] as String? ?? '',
      story: json['story'] as String? ?? '',
      avatarUrl: json['avatarS3'] as String? ?? '',
      coverUrl: json['displayPhotoS3'] as String? ?? '',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      phone: json['phone'] as String? ?? '',
      availability: _parseAvailability(json['availability']),
      memberSince: memberSinceRaw != null
          ? DateTime.parse(memberSinceRaw)
          : DateTime(2016),
      photoUrl: json['photoUrl'] as String?,
      producerAddress: producerAddress,
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
    return '';
  }

  static List<AvailabilitySlot> _parseAvailability(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((a) {
      final slot = a as Map<String, dynamic>;
      return AvailabilitySlot(
        weekday: slot['weekday'] as int,
        opensAt: slot['opensAt'] as String? ?? '',
        closesAt: slot['closesAt'] as String? ?? '',
      );
    }).toList();
  }
}
