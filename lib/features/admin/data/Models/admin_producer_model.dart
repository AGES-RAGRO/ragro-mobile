import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';

class AdminProducerModel extends AdminProducer {
  const AdminProducerModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    required super.createdAt,
    required super.updatedAt,
    required super.active,
  });

  factory AdminProducerModel.fromJson(Map<String, dynamic> json) {
    return AdminProducerModel(
      id: json['id'] as String ?? '',
      name: json['name'] as String ?? '',
      email: json['email'] as String ?? '',
      phone: json['phone'] as String ?? '',
      address: json['address'] as String ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String ?? DateTime.now().toIso8601String()),
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'active': active,
    };
  }

  factory AdminProducerModel.fromEntity(AdminProducer entity) {
    return AdminProducerModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      address: entity.address,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      active: entity.active,
    );
  }
}

