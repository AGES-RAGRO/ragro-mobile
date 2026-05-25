import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/recommendations/domain/usecases/get_recommendations_usecase.dart';
import 'package:ragro_mobile/features/recommendations/presentation/bloc/recommendations_event.dart';
import 'package:ragro_mobile/features/recommendations/presentation/bloc/recommendations_state.dart';

@injectable
class RecommendationsBloc
    extends Bloc<RecommendationsEvent, RecommendationsState> {
  RecommendationsBloc(this._getRecommendations)
      : super(const RecommendationsInitial()) {
    on<RecommendationsStarted>(_onStarted);
    on<RecommendationsRefreshRequested>(_onRefreshRequested);
  }

  final GetRecommendationsUsecase _getRecommendations;

  Future<void> _onStarted(
    RecommendationsStarted event,
    Emitter<RecommendationsState> emit,
  ) async {
    emit(const RecommendationsLoading());
    await _fetchRecommendations(emit);
  }

  Future<void> _onRefreshRequested(
    RecommendationsRefreshRequested event,
    Emitter<RecommendationsState> emit,
  ) async {
    emit(const RecommendationsLoading());
    await _fetchRecommendations(emit);
  }

  Future<void> _fetchRecommendations(
    Emitter<RecommendationsState> emit,
  ) async {
    try {
      final recommendations = await _getRecommendations();
      if (recommendations.isEmpty) {
        emit(const RecommendationsEmpty());
      } else {
        emit(RecommendationsLoaded(recommendations));
      }
    } on ApiException catch (e) {
      emit(RecommendationsError(e.message));
    } on Exception catch (_) {
      emit(const RecommendationsError('Não foi possível carregar as recomendações.'));
    }
  }
}
