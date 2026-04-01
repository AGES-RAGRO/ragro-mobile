import 'package:equatable/equatable.dart';

sealed class ProducerProfileEvent extends Equatable {
  const ProducerProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProducerProfileStarted extends ProducerProfileEvent {
  const ProducerProfileStarted(this.producerId);
  final String producerId;

  @override
  List<Object?> get props => [producerId];
}
