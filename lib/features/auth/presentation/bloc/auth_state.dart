import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}

class AuthPasswordResetInProgress extends AuthAuthenticated {
  const AuthPasswordResetInProgress(super.user);
}

class AuthPasswordResetSuccess extends AuthAuthenticated {
  const AuthPasswordResetSuccess(super.user);
}

class AuthPasswordResetFailure extends AuthAuthenticated {
  const AuthPasswordResetFailure(super.user, this.message);
  final String message;
  @override
  List<Object?> get props => [user, message];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
