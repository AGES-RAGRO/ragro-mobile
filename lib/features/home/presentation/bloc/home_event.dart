import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {
  const HomeStarted();
}

class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}

class HomeLoadMoreProducers extends HomeEvent {
  const HomeLoadMoreProducers();
}

class HomeLoadMoreProducts extends HomeEvent {
  const HomeLoadMoreProducts();
}
