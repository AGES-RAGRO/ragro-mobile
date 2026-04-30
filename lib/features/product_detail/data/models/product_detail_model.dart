import 'package:ragro_mobile/features/product_detail/domain/entities/product_detail.dart';

class ProductDetailModel extends ProductDetail {
  const ProductDetailModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.unityType,
    required super.category,
    required super.imageUrl,
    required super.farmName,
    required super.producerName,
    required super.producerId,
    required super.stockQuantity,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'] as List<dynamic>?;
    final photos = json['photos'] as List<dynamic>?;
    final firstCategory = categories != null && categories.isNotEmpty
        ? (categories.first as Map<String, dynamic>)['name'] as String? ?? ''
        : '';
    final firstPhotoUrl = photos != null && photos.isNotEmpty
        ? (photos.first as Map<String, dynamic>)['url'] as String? ?? ''
        : '';
    final imageUrl = firstPhotoUrl.isNotEmpty
        ? firstPhotoUrl
        : (json['imageS3'] as String? ?? '');
    return ProductDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      unityType: json['unityType'] as String? ?? 'kg',
      category: firstCategory,
      imageUrl: imageUrl,
      farmName: '',
      producerName: '',
      producerId: json['farmerId'] as String? ?? '',
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  const ProductDetailModel.mock()
    : this(
        id: 'product_1',
        name: 'Tomate',
        description:
            'Os Tomates da fazenda Sol Nascente são cultivados em solos férteis com irrigação equilibrada e acompanhamento constante, crescendo de forma saudável sob a luz natural até atingir sua cor vermelha intensa; quando chega ao ponto ideal de maturação, a colheita é feita manualmente para preservar sua textura firme e sabor adocicado.',
        price: 8.90,
        unityType: 'kg',
        category: 'Hortaliças',
        imageUrl: '',
        farmName: 'Fazenda Sol Nascente',
        producerName: 'João Nascimento',
        producerId: 'producer_1',
        stockQuantity: 50,
      );
}
