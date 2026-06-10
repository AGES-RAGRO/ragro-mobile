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

  /// Janela mínima entre buscas via pull-to-refresh. O backend cacheia o ranking
  /// por cliente (TTL horas), então refreshes em sequência só repetiriam a mesma
  /// resposta — e antes do throttle cada puxada podia custar uma chamada de LLM.
  static const _refreshThrottle = Duration(seconds: 30);

  DateTime? _lastFetchAt;

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
    final last = _lastFetchAt;
    if (last != null && DateTime.now().difference(last) < _refreshThrottle) {
      return; // mantém o estado atual sem nova chamada de rede
    }
    // Sem emitir Loading: a lista atual permanece visível durante o refresh
    // (antes os cards recomendados sumiam a cada puxada).
    await _fetchRecommendations(emit, previous: state);
  }

  Future<void> _fetchRecommendations(
    Emitter<RecommendationsState> emit, {
    RecommendationsState? previous,
  }) async {
    try {
      final recommendations = await _getRecommendations();
      _lastFetchAt = DateTime.now();
      if (recommendations.isEmpty) {
        emit(const RecommendationsEmpty());
      } else {
        emit(RecommendationsLoaded(recommendations));
      }
    } on ApiException catch (e) {
      // Refresh que falha não derruba a lista que o usuário já vê.
      if (previous is! RecommendationsLoaded) {
        emit(RecommendationsError(e.message));
      }
    } on Exception catch (_) {
      if (previous is! RecommendationsLoaded) {
        emit(
          const RecommendationsError(
            'Não foi possível carregar as recomendações.',
          ),
        );
      }
    }
  }
}
