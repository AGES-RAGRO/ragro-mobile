import 'package:equatable/equatable.dart';

sealed class RecommendationsEvent extends Equatable {
  const RecommendationsEvent();
  @override
  List<Object?> get props => [];
}

class RecommendationsStarted extends RecommendationsEvent {
  const RecommendationsStarted();
}

class RecommendationsRefreshRequested extends RecommendationsEvent {
  const RecommendationsRefreshRequested();
}
