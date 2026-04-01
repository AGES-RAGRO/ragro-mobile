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
  const HomeLoaded({required this.producers, required this.products});

  final List<Producer> producers;
  final List<HomeProduct> products;

  @override
  List<Object?> get props => [producers, products];
}

class HomeFailure extends HomeState {
  const HomeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
