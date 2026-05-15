import 'package:equatable/equatable.dart';

class StockMovement extends Equatable {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.reason,
    required this.quantity,
    required this.createdAt,
    required this.currentStockQuantity,
    this.notes,
  });

  final String id;
  final String productId;
  final String productName;
  final String type; // 'ENTRY' | 'EXIT'
  final String reason; // 'SALE' | 'LOSS' | 'DISPOSAL' | 'MANUAL_ENTRY' | 'CANCELED_SALE'
  final double quantity;
  final String? notes;
  final DateTime createdAt;
  final double currentStockQuantity;

  factory StockMovement.fromJson(Map<String, dynamic> json) => StockMovement(
    id: (json['id'] as String?) ?? '',
    productId: (json['productId'] as String?) ?? '',
    productName: (json['productName'] as String?) ?? '',
    type: (json['type'] as String?) ?? '',
    reason: (json['reason'] as String?) ?? '',
    quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
    notes: json['notes'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
    currentStockQuantity:
        (json['currentStockQuantity'] as num?)?.toDouble() ?? 0.0,
  );

  String get reasonLabel => switch (reason) {
    'SALE' => 'Venda',
    'LOSS' => 'Perda',
    'DISPOSAL' => 'Descarte',
    'MANUAL_ENTRY' => 'Ajuste Manual',
    'CANCELED_SALE' => 'Cancelamento',
    _ => reason,
  };

  @override
  List<Object?> get props => [id, productId, type, reason, quantity, createdAt];
}
