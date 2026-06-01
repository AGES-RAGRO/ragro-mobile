// Events the screen dispatches to the BLoC; sealed and compared by value.

import 'package:equatable/equatable.dart';

sealed class LearningEvent extends Equatable {
  const LearningEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the screen loads or the user taps "try again".
class LearningProductsRequested extends LearningEvent {
  const LearningProductsRequested();
}
