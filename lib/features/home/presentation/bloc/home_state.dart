import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.producers,
    required this.products,
    this.currentProducersPage = 0,
    this.hasMoreProducers = true,
    this.isFetchingMoreProducers = false,
  });

  final List<Producer> producers;
  final List<HomeProduct> products;
  final int currentProducersPage;
  final bool hasMoreProducers;
  final bool isFetchingMoreProducers;

  HomeLoaded copyWith({
    List<Producer>? producers,
    List<HomeProduct>? products,
    int? currentProducersPage,
    bool? hasMoreProducers,
    bool? isFetchingMoreProducers,
  }) {
    return HomeLoaded(
      producers: producers ?? this.producers,
      products: products ?? this.products,
      currentProducersPage: currentProducersPage ?? this.currentProducersPage,
      hasMoreProducers: hasMoreProducers ?? this.hasMoreProducers,
      isFetchingMoreProducers: isFetchingMoreProducers ?? this.isFetchingMoreProducers,
    );
  }

  @override
  List<Object?> get props => [
    producers,
    products,
    currentProducersPage,
    hasMoreProducers,
    isFetchingMoreProducers,
  ];
}

class HomeFailure extends HomeState {
  const HomeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
