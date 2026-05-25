class Recommendation {
  const Recommendation({
    required this.id,
    required this.name,
    required this.price,
    required this.unityType,
    required this.imageS3,
    required this.farmerId,
    required this.farmName,
    required this.categoryNames,
    required this.score,
    required this.reason,
  });

  final String id;
  final String name;
  final double price;
  final String unityType;
  final String? imageS3;
  final String farmerId;
  final String farmName;
  final List<String> categoryNames;
  final int score;
  final String reason;
}
