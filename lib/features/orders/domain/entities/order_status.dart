enum OrderStatus { pending, accepted, inDelivery, delivered, cancelled }

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => 'PENDENTE',
    OrderStatus.accepted => 'ACEITO',
    OrderStatus.inDelivery => 'A CAMINHO',
    OrderStatus.delivered => 'ENTREGUE',
    OrderStatus.cancelled => 'CANCELADO',
  };

  /// Value exchanged with the backend (Java OrderStatus enum, UPPERCASE).
  String get backendValue => switch (this) {
    OrderStatus.pending => 'PENDING',
    OrderStatus.accepted => 'CONFIRMED',
    OrderStatus.inDelivery => 'IN_DELIVERY',
    OrderStatus.delivered => 'DELIVERED',
    OrderStatus.cancelled => 'CANCELLED',
  };
}
