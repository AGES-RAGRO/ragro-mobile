// DATA/MODELS — O "tradutor" da cozinha.
// O Model sabe converter JSON (que vem da API) em um objeto Dart.
// Extends Product (Entity) — ou seja, um ProductModel É um Product, mas com superpoderes de parsing.
// Fica no data/ porque depende de JSON. O domain/ nunca sabe que isso existe.

import 'package:ragro_mobile/features/learning/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}
