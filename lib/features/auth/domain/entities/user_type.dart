enum UserType {
  consumer,
  producer,
  admin;

  /// Maps API/DB values ('customer', 'farmer', 'admin') to domain enum.
  static UserType fromApiValue(String value) {
    return switch (value) {
      'customer' || 'consumer' => UserType.consumer,
      'farmer'   || 'producer' => UserType.producer,
      'admin'                  => UserType.admin,
      _ => throw ArgumentError('Unknown user type: $value'),
    };
  }
}
