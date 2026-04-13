import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/customer_profile/domain/entities/customer_profile.dart';

sealed class CustomerProfileState extends Equatable {
  const CustomerProfileState();

  @override
  List<Object?> get props => [];
}

class CustomerProfileInitial extends CustomerProfileState {
  const CustomerProfileInitial();
}

class CustomerProfileLoading extends CustomerProfileState {
  const CustomerProfileLoading();
}

class CustomerProfileLoaded extends CustomerProfileState {
  const CustomerProfileLoaded(this.profile);
  final CustomerProfile profile;

  @override
  List<Object?> get props => [profile];
}

class CustomerProfileUpdating extends CustomerProfileState {
  const CustomerProfileUpdating(this.profile);
  final CustomerProfile profile;

  @override
  List<Object?> get props => [profile];
}

class CustomerProfileUpdateSuccess extends CustomerProfileState {
  const CustomerProfileUpdateSuccess(this.profile);
  final CustomerProfile profile;

  @override
  List<Object?> get props => [profile];
}

class CustomerProfileUpdateFailure extends CustomerProfileState {
  const CustomerProfileUpdateFailure(this.profile, this.message);
  final CustomerProfile profile;
  final String message;

  @override
  List<Object?> get props => [profile, message];
}

class CustomerProfileFailure extends CustomerProfileState {
  const CustomerProfileFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
