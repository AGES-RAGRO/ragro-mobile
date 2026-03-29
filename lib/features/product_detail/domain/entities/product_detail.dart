import 'package:equatable/equatable.dart';

class ProductDetail extends Equatable {
  const ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unityType,
    required this.category,
    required this.imageUrl,
    required this.farmName,
    required this.producerName,
    required this.producerId,
    required this.stockQuantity,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String unityType;
  final String category;
  final String imageUrl;
  final String farmName;
  final String producerName;
  final String producerId;
  final double stockQuantity;

  @override
  List<Object?> get props => [id, name, price];
}
