enum OrderStatus { pending, accepted, inDelivery, delivered, cancelled }

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => 'PENDENTE',
    OrderStatus.accepted => 'ACEITO',
    OrderStatus.inDelivery => 'A CAMINHO',
    OrderStatus.delivered => 'ENTREGUE',
    OrderStatus.cancelled => 'CANCELADO',
  };
}
