/// Canonical order status, shared by the consumer (`orders`) and producer
/// (`producer_orders`) features.
///
/// Mirrors the backend Java enum (case-sensitive UPPERCASE):
/// ragro-backend/src/main/java/br/com/ragro/domain/enums/OrderStatus.java
/// (PENDING / CONFIRMED / IN_DELIVERY / DELIVERED / CANCELLED).
enum OrderStatus {
  pending('PENDING', 'Pendente'),
  accepted('CONFIRMED', 'Aceito'),
  inDelivery('IN_DELIVERY', 'A caminho'),
  delivered('DELIVERED', 'Entregue'),
  cancelled('CANCELLED', 'Cancelado');

  const OrderStatus(this.apiValue, this.label);

  /// Exact value exchanged with the backend.
  final String apiValue;

  /// Human-readable label (pt-BR).
  final String label;

  /// Parses one of the 5 canonical backend values (case-insensitive).
  ///
  /// Returns null for anything else; status parsing callers fall back to
  /// [pending] for unknown values.
  static OrderStatus? tryParse(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final status in values) {
      if (status.apiValue == normalized) return status;
    }
    return null;
  }
}
