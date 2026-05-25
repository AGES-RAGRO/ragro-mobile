class ProducerLocation {
  ProducerLocation({
    required this.id,
    required this.farmName,
    required this.latitude,
    required this.longitude,
  });

  factory ProducerLocation.fromJson(Map<String, dynamic> json) {
    return ProducerLocation(
      id: json['id'] as String,
      farmName: json['farmName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
  final String id;
  final String farmName;
  final double latitude;
  final double longitude;
}
