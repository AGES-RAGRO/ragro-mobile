import 'package:equatable/equatable.dart';

sealed class RateProducerEvent extends Equatable {
  const RateProducerEvent();
  @override
  List<Object?> get props => [];
}

class RateProducerStarSelected extends RateProducerEvent {
  const RateProducerStarSelected(this.rating);
  final int rating;
  @override
  List<Object?> get props => [rating];
}

class RateProducerCommentChanged extends RateProducerEvent {
  const RateProducerCommentChanged(this.comment);
  final String comment;
  @override
  List<Object?> get props => [comment];
}

class RateProducerSubmitted extends RateProducerEvent {
  const RateProducerSubmitted(this.orderId, this.rating, this.comment);
  final String orderId;
  final int rating;
  final String comment;
  @override
  List<Object?> get props => [orderId, rating, comment];
}
