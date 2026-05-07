import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/review.dart';

class AvailabilitySlot extends Equatable {
  const AvailabilitySlot({
    required this.weekday,
    required this.opensAt,
    required this.closesAt,
  });

  final int weekday; // 0=Sun, 1=Mon ... 6=Sat
  final String opensAt;
  final String closesAt;

  @override
  List<Object?> get props => [weekday, opensAt, closesAt];
}

class ProducerAddress extends Equatable {
  const ProducerAddress({
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    required this.zipCode,
    this.complement,
    this.neighborhood,
    this.latitude,
    this.longitude,
  });

  final String street;
  final String number;
  final String city;
  final String state;
  final String zipCode;
  final String? complement;
  final String? neighborhood;
  final double? latitude;
  final double? longitude;

  @override
  List<Object?> get props => [
    street,
    number,
    city,
    state,
    zipCode,
    complement,
    neighborhood,
    latitude,
    longitude,
  ];
}

class ProducerPaymentMethod extends Equatable {
  const ProducerPaymentMethod({
    required this.type,
    this.pixKeyType,
    this.pixKey,
    this.bankCode,
    this.bankName,
    this.agency,
    this.accountNumber,
    this.accountType,
    this.holderName,
    this.fiscalNumber,
  });

  final String type; // 'pix', 'bank_account', etc
  final String? pixKeyType; // 'cpf', 'cnpj', 'email', 'phone', 'random'
  final String? pixKey;
  final String? bankCode;
  final String? bankName;
  final String? agency;
  final String? accountNumber;
  final String? accountType;
  final String? holderName;
  final String? fiscalNumber;

  @override
  List<Object?> get props => [
    type,
    pixKeyType,
    pixKey,
    bankCode,
    bankName,
    agency,
    accountNumber,
    accountType,
    holderName,
    fiscalNumber,
  ];
}

class PublicProducer extends Equatable {
  const PublicProducer({
    required this.id,
    required this.name,
    required this.farmName,
    required this.location,
    required this.description,
    required this.story,
    required this.avatarUrl,
    required this.coverUrl,
    required this.averageRating,
    required this.totalReviews,
    required this.phone,
    required this.availability,
    required this.memberSince,
    this.photoUrl,
    this.producerAddress,
    this.paymentMethods,
    this.products,
    this.reviews,
  });

  final String id;
  final String name;
  final String farmName;
  final String location;
  final String description;
  final String story;
  final String avatarUrl;
  final String coverUrl;
  final double averageRating;
  final int totalReviews;
  final String phone;
  final List<AvailabilitySlot> availability;
  final DateTime memberSince;

  final String? photoUrl;
  final ProducerAddress? producerAddress;
  final List<ProducerPaymentMethod>? paymentMethods;
  final List<HomeProduct>? products;
  final List<Review>? reviews;

  int get yearsOnPlatform {
    return DateTime.now().difference(memberSince).inDays ~/ 365;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    farmName,
    location,
    description,
    story,
    avatarUrl,
    coverUrl,
    averageRating,
    totalReviews,
    phone,
    availability,
    memberSince,
    photoUrl,
    producerAddress,
    paymentMethods,
    products,
    reviews,
  ];
}
