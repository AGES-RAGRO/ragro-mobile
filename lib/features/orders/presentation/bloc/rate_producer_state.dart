import 'package:equatable/equatable.dart';

sealed class RateProducerState extends Equatable {
  const RateProducerState();
  @override
  List<Object?> get props => [];
}

class RateProducerInitial extends RateProducerState {
  const RateProducerInitial({
    this.selectedRating = 0,
    this.comment = '',
  });

  final int selectedRating;
  final String comment;

  @override
  List<Object?> get props => [selectedRating, comment];
}

class RateProducerSubmitting extends RateProducerState {
  const RateProducerSubmitting({
    required this.selectedRating,
    required this.comment,
  });

  final int selectedRating;
  final String comment;

  @override
  List<Object?> get props => [selectedRating, comment];
}

class RateProducerSuccess extends RateProducerState {
  const RateProducerSuccess();
}

class RateProducerFailure extends RateProducerState {
  const RateProducerFailure(
    this.message, {
    required this.selectedRating,
    required this.comment,
  });

  final String message;
  final int selectedRating;
  final String comment;

  @override
  List<Object?> get props => [message, selectedRating, comment];
}
