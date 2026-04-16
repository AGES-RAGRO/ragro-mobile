enum OrderStatus { pending, accepted, delivered, cancelled }

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => 'PENDENTE',
    OrderStatus.accepted => 'ACEITO',
    OrderStatus.delivered => 'ENTREGUE',
    OrderStatus.cancelled => 'CANCELADO',
  };
}
