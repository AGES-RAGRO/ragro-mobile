import 'package:equatable/equatable.dart';

class AdminAvailability extends Equatable {
  const AdminAvailability({
    required this.weekday,
    required this.opensAt,
    required this.closesAt,
  });

  final int weekday;
  final String opensAt;
  final String closesAt;

  Map<String, dynamic> toJson() => {
    'weekday': weekday,
    'opensAt': opensAt,
    'closesAt': closesAt,
  };

  @override
  List<Object?> get props => [weekday, opensAt, closesAt];
}
