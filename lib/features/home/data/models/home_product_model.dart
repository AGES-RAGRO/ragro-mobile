import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';

class HomeProductModel extends HomeProduct {
  const HomeProductModel({
    required super.id,
    required super.name,
    required super.category,
    required super.price,
    required super.imageUrl,
    required super.farmName,
    required super.producerId,
  });

  factory HomeProductModel.fromJson(Map<String, dynamic> json) {
    return HomeProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl:
          json['image_s3'] as String? ?? json['imageUrl'] as String? ?? '',
      farmName: json['farm_name'] as String? ?? '',
      producerId:
          json['farmer_id'] as String? ?? json['producerId'] as String? ?? '',
    );
  }

  static List<HomeProductModel> mocks() {
    return [
      const HomeProductModel(
        id: 'p1',
        name: 'Kiwi Orgânico',
        category: 'FRUTAS',
        price: 8.90,
        imageUrl: '',
        farmName: 'Fazenda Sol Nascente',
        producerId: 'producer_1',
      ),
      const HomeProductModel(
        id: 'p2',
        name: 'Alface Crespa',
        category: 'HORTA',
        price: 3.50,
        imageUrl: '',
        farmName: 'Fazenda Sol Nascente',
        producerId: 'producer_1',
      ),
      const HomeProductModel(
        id: 'p3',
        name: 'Tomate Cereja',
        category: 'HORTA',
        price: 12.90,
        imageUrl: '',
        farmName: 'Sítio Verde Vivo',
        producerId: 'producer_2',
      ),
      const HomeProductModel(
        id: 'p4',
        name: 'Manga Palmer',
        category: 'FRUTAS',
        price: 6.00,
        imageUrl: '',
        farmName: 'Sítio Verde Vivo',
        producerId: 'producer_2',
      ),
    ];
  }
}
