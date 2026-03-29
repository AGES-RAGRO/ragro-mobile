import 'package:equatable/equatable.dart';

sealed class RateProducerEvent extends Equatable {
  const RateProducerEvent();
  @override
  List<Object?> get props => [];
}

class RateProducerStarted extends RateProducerEvent {
  const RateProducerStarted(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

class RateProducerStarSelected extends RateProducerEvent {
  const RateProducerStarSelected(this.rating);
  final int rating;
  @override
  List<Object?> get props => [rating];
}

class RateProducerSubmitted extends RateProducerEvent {
  const RateProducerSubmitted(this.orderId, this.rating);
  final String orderId;
  final int rating;
  @override
  List<Object?> get props => [orderId, rating];
}
