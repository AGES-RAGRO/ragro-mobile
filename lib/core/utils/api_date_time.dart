/// Converte timestamps da API (ISO-8601 com offset/Z) para o fuso local do aparelho.
///
/// O backend serializa `OffsetDateTime` em UTC; exibir o resultado de
/// `DateTime.parse` sem `toLocal()` mostra horário 3h adiantado no fuso de
/// Brasília (auditoria Fase 0 — o detalhe do pedido divergia da lista).
/// Use SEMPRE este helper ao parsear datas vindas da API.
DateTime? parseApiDateTime(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}
