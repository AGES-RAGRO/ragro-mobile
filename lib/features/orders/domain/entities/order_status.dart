enum OrderStatus { pending, accepted, inDelivery, delivered, cancelled }

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => 'PENDENTE',
    OrderStatus.accepted => 'ACEITO',
    OrderStatus.inDelivery => 'A CAMINHO',
    OrderStatus.delivered => 'ENTREGUE',
    OrderStatus.cancelled => 'CANCELADO',
  };

  /// Valor enviado/recebido pelo backend (Java OrderStatus, UPPERCASE).
  /// Ver ragro-backend/src/main/java/br/com/ragro/domain/enums/OrderStatus.java
  String get backendValue => switch (this) {
    OrderStatus.pending => 'PENDING',
    OrderStatus.accepted => 'CONFIRMED',
    OrderStatus.inDelivery => 'IN_DELIVERY',
    OrderStatus.delivered => 'DELIVERED',
    OrderStatus.cancelled => 'CANCELLED',
  };
}
