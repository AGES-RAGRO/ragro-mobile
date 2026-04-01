import 'package:equatable/equatable.dart';

sealed class RateProducerState extends Equatable {
  const RateProducerState();
  @override
  List<Object?> get props => [];
}

class RateProducerInitial extends RateProducerState {
  const RateProducerInitial({this.selectedRating = 0});
  final int selectedRating;
  @override
  List<Object?> get props => [selectedRating];
}

class RateProducerSubmitting extends RateProducerState {
  const RateProducerSubmitting();
}

class RateProducerSuccess extends RateProducerState {
  const RateProducerSuccess();
}

class RateProducerFailure extends RateProducerState {
  const RateProducerFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
