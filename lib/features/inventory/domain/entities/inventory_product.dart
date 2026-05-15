import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';

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
    this.categoryIds = const [],
  });

  final String id;
  final String producerId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String unit;
  final double stock;
  final bool active;
  final List<int> categoryIds;

  factory InventoryProduct.fromJson(Map<String, dynamic> json) =>
      InventoryProduct(
        id: (json['id'] as String?) ?? '',
        producerId: (json['farmerId'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        imageUrl: ApiEndpoints.resolveMediaUrl((json['imageS3'] as String?) ?? ''),
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        unit: (json['unityType'] as String?) ?? 'un',
        stock: (json['stockQuantity'] as num?)?.toDouble() ?? 0.0,
        active: (json['active'] as bool?) ?? true,
        categoryIds: (json['categories'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map((c) => c['id'] as int)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    'unityType': unit,
    'stockQuantity': stock,
    if (imageUrl.isNotEmpty) 'imageS3': imageUrl,
    'active': active,
    if (categoryIds.isNotEmpty) 'categoryIds': categoryIds,
  };

  InventoryProduct copyWith({
    String? id,
    String? producerId,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    String? unit,
    double? stock,
    bool? active,
    List<int>? categoryIds,
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
      categoryIds: categoryIds ?? this.categoryIds,
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
