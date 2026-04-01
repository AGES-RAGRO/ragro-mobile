enum ProducerOrderStatus { pending, accepted, inDelivery, delivered, cancelled }

extension ProducerOrderStatusLabel on ProducerOrderStatus {
  String get label => switch (this) {
        ProducerOrderStatus.pending => 'Pendente',
        ProducerOrderStatus.accepted => 'Aceito',
        ProducerOrderStatus.inDelivery => 'A caminho',
        ProducerOrderStatus.delivered => 'Entregue',
        ProducerOrderStatus.cancelled => 'Cancelado',
      };
}
