import 'package:ragro_mobile/features/admin/domain/entities/admin_producer_summary.dart';

class AdminProducerSummaryModel extends AdminProducerSummary {
  const AdminProducerSummaryModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminProducerSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminProducerSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
