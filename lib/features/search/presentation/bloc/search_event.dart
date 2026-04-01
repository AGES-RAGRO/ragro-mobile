import 'package:equatable/equatable.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchCategoryChanged extends SearchEvent {
  const SearchCategoryChanged(this.category);
  final String? category;

  @override
  List<Object?> get props => [category];
}

class SearchRecentItemRemoved extends SearchEvent {
  const SearchRecentItemRemoved(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}
