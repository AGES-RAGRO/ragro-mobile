import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/search/domain/entities/search_result.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchIdle extends SearchState {
  const SearchIdle({this.recentSearches = const []});
  final List<String> recentSearches;

  @override
  List<Object?> get props => [recentSearches];
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  const SearchLoaded({required this.results, required this.query});
  final List<SearchResult> results;
  final String query;

  @override
  List<Object?> get props => [results, query];
}

class SearchFailure extends SearchState {
  const SearchFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
