import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();
  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}

class RegisterFailure extends RegisterState {
  const RegisterFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
