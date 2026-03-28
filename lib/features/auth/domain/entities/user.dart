import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.active,
    this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserType type;
  final bool active;

  @override
  List<Object?> get props => [id, email, type];
}
