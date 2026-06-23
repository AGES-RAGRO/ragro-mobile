/// Parses API timestamps (ISO-8601 with offset/Z) to the device's local zone.
///
/// Backend serializes `OffsetDateTime` in UTC; without `toLocal()` times show
/// 3h ahead in Brasilia. Always use this helper when parsing API dates.
DateTime? parseApiDateTime(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}
