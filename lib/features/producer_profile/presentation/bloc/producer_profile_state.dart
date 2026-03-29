import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';

sealed class ProducerProfileState extends Equatable {
  const ProducerProfileState();

  @override
  List<Object?> get props => [];
}

class ProducerProfileInitial extends ProducerProfileState {
  const ProducerProfileInitial();
}

class ProducerProfileLoading extends ProducerProfileState {
  const ProducerProfileLoading();
}

class ProducerProfileLoaded extends ProducerProfileState {
  const ProducerProfileLoaded(this.producer);
  final PublicProducer producer;

  @override
  List<Object?> get props => [producer];
}

class ProducerProfileFailure extends ProducerProfileState {
  const ProducerProfileFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
