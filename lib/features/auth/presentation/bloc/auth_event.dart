import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoggedIn extends AuthEvent {
  const AuthLoggedIn(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
