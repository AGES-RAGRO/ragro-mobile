import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';

class AdminProducerModel extends AdminProducer {
  const AdminProducerModel({
    required super.id,
    required super.name,
    required super.email,
    required super.location,
    required super.address,
    required super.createdAt,
    required super.updatedAt,
    required super.active,
  });

  factory AdminProducerModel.fromJson(Map<String, dynamic> json) {
    return AdminProducerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      location: json['location'] as String,
      address: json['address'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      active: json['active'] as bool,
    );
  }
}

