enum UserType {
  customer,
  producer,
  admin;

  /// Maps API/DB values ('customer', 'farmer', 'admin') to domain enum.
  static UserType fromApiValue(String value) {
    return switch (value) {
      'customer' || 'consumer' => UserType.customer,
      'farmer' || 'producer' => UserType.producer,
      'admin' => UserType.admin,
      _ => throw ArgumentError('Unknown user type: $value'),
    };
  }
}
