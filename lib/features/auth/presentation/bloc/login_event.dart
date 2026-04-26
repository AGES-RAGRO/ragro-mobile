import 'package:equatable/equatable.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class LoginForgotPasswordRequested extends LoginEvent {
  const LoginForgotPasswordRequested(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}
