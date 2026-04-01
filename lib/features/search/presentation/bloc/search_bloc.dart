import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/search/domain/usecases/search_producers_and_products.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_state.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._search) : super(const SearchIdle()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCategoryChanged>(_onCategoryChanged);
    on<SearchRecentItemRemoved>(_onRecentRemoved);
  }

  final SearchProducersAndProducts _search;
  String _currentCategory = 'Tudo';

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      final recent = state is SearchIdle ? (state as SearchIdle).recentSearches : <String>[];
      emit(SearchIdle(recentSearches: recent));
      return;
    }
    emit(const SearchLoading());
    try {
      final results = await _search(
        query: event.query,
        category: _currentCategory == 'Tudo' ? null : _currentCategory,
      );
      emit(SearchLoaded(results: results, query: event.query));
    } on ApiException catch (e) {
      emit(SearchFailure(e.message));
    } catch (_) {
      emit(const SearchFailure('Erro ao buscar. Tente novamente.'));
    }
  }

  Future<void> _onCategoryChanged(
    SearchCategoryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _currentCategory = event.category ?? 'Tudo';
  }

  void _onRecentRemoved(SearchRecentItemRemoved event, Emitter<SearchState> emit) {
    if (state is SearchIdle) {
      final recent = List<String>.from((state as SearchIdle).recentSearches)
        ..remove(event.query);
      emit(SearchIdle(recentSearches: recent));
    }
  }
}
