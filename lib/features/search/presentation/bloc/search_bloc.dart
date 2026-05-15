import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/search/data/datasources/search_local_datasource.dart';
import 'package:ragro_mobile/features/search/domain/usecases/search_producers_and_products.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_state.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._search, this._local) : super(const SearchIdle()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCategoryChanged>(_onCategoryChanged);
    on<SearchQuerySubmitted>(_onQuerySubmitted);
    on<SearchRecentItemRemoved>(_onRecentRemoved);
    on<SearchLoadRecentSearches>(_onLoadRecent);
    add(const SearchLoadRecentSearches());
  }

  final SearchProducersAndProducts _search;
  final SearchLocalDataSource _local;
  String _currentCategory = 'Tudo';

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      final recent = state is SearchIdle
          ? (state as SearchIdle).recentSearches
          : <String>[];
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
    } on Exception catch (_) {
      emit(const SearchFailure('Erro ao buscar. Tente novamente.'));
    }
  }

  Future<void> _onCategoryChanged(
    SearchCategoryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _currentCategory = event.category ?? 'Tudo';
  }

  Future<void> _onQuerySubmitted(
    SearchQuerySubmitted event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) return;
    await _local.addRecentSearch(event.query);
    final recent = _local.getRecentSearches();
    emit(SearchIdle(recentSearches: recent));
  }

  void _onRecentRemoved(
    SearchRecentItemRemoved event,
    Emitter<SearchState> emit,
  ) {
    if (state is SearchIdle) {
      _local.removeRecentSearch(event.query);
      final recent = List<String>.from((state as SearchIdle).recentSearches)
        ..remove(event.query);
      emit(SearchIdle(recentSearches: recent));
    }
  }

  Future<void> _onLoadRecent(
    SearchLoadRecentSearches event,
    Emitter<SearchState> emit,
  ) async {
    final recent = _local.getRecentSearches();
    if (recent.isNotEmpty) {
      emit(SearchIdle(recentSearches: recent));
    }
  }
}
