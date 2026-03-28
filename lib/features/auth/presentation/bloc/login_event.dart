import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({
    required this.email,
    required this.password,
    required this.userType,
  });

  final String email;
  final String password;
  final UserType userType;

  @override
  List<Object?> get props => [email, password, userType];
}
