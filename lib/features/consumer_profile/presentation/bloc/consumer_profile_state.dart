import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/entities/consumer_profile.dart';

sealed class ConsumerProfileState extends Equatable {
  const ConsumerProfileState();

  @override
  List<Object?> get props => [];
}

class ConsumerProfileInitial extends ConsumerProfileState {
  const ConsumerProfileInitial();
}

class ConsumerProfileLoading extends ConsumerProfileState {
  const ConsumerProfileLoading();
}

class ConsumerProfileLoaded extends ConsumerProfileState {
  const ConsumerProfileLoaded(this.profile);
  final CustomerProfile profile;

  @override
  List<Object?> get props => [profile];
}

class ConsumerProfileUpdating extends ConsumerProfileState {
  const ConsumerProfileUpdating(this.profile);
  final CustomerProfile profile;

  @override
  List<Object?> get props => [profile];
}

class ConsumerProfileUpdateSuccess extends ConsumerProfileState {
  const ConsumerProfileUpdateSuccess(this.profile);
  final CustomerProfile profile;

  @override
  List<Object?> get props => [profile];
}

class ConsumerProfileFailure extends ConsumerProfileState {
  const ConsumerProfileFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
