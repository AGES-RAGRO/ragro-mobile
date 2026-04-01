import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';

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
    required this.totalOrders,
    required this.phone,
    required this.products,
    required this.availability,
    required this.memberSince,
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
  final int totalOrders;
  final String phone;
  final List<HomeProduct> products;
  final List<AvailabilitySlot> availability;
  final DateTime memberSince;

  int get yearsOnPlatform {
    return DateTime.now().difference(memberSince).inDays ~/ 365;
  }

  @override
  List<Object?> get props => [id, farmName, averageRating, products.length];
}
