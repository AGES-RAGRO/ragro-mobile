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

  factory InventoryProduct.fromJson(Map<String, dynamic> json) =>
      InventoryProduct(
        id: (json['id'] as String?) ?? '',
        producerId: (json['farmerId'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        imageUrl: (json['imageS3'] as String?) ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        unit: (json['unityType'] as String?) ?? 'un',
        stock:
            ((json['stockQuantity'] as num?)?.toDouble() ?? 0.0).round(),
        active: (json['active'] as bool?) ?? true,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    'unityType': unit,
    'stockQuantity': stock,
    if (imageUrl.isNotEmpty) 'imageS3': imageUrl,
    'active': active,
  };

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
