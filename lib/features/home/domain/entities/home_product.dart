import 'package:equatable/equatable.dart';

class HomeProduct extends Equatable {
  const HomeProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.farmName,
    required this.producerId,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String farmName;
  final String producerId;

  @override
  List<Object?> get props => [id, name, category, price, imageUrl, farmName, producerId];
}
