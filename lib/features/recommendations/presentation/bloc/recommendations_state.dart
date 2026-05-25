import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/recommendations/domain/entities/recommendation.dart';

sealed class RecommendationsState extends Equatable {
  const RecommendationsState();
  @override
  List<Object?> get props => [];
}

class RecommendationsInitial extends RecommendationsState {
  const RecommendationsInitial();
}

class RecommendationsLoading extends RecommendationsState {
  const RecommendationsLoading();
}

class RecommendationsLoaded extends RecommendationsState {
  const RecommendationsLoaded(this.recommendations);
  final List<Recommendation> recommendations;
  @override
  List<Object?> get props => [recommendations];
}

class RecommendationsEmpty extends RecommendationsState {
  const RecommendationsEmpty();
}

class RecommendationsError extends RecommendationsState {
  const RecommendationsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
