import 'package:equatable/equatable.dart';

class InventoryProduct extends Equatable {
  const InventoryProduct({
    required this.id,
    required this.producerId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.unit,
    required this.stock,
    required this.active,
  });

  final String id;
  final String producerId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String unit;
  final int stock;
  final bool active;

  InventoryProduct copyWith({
    String? id,
    String? producerId,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    String? unit,
    int? stock,
    bool? active,
  }) {
    return InventoryProduct(
      id: id ?? this.id,
      producerId: producerId ?? this.producerId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [
    id,
    producerId,
    name,
    description,
    imageUrl,
    price,
    unit,
    stock,
    active,
  ];
}
