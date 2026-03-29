import 'package:equatable/equatable.dart';

sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class ProductDetailStarted extends ProductDetailEvent {
  const ProductDetailStarted(this.productId);
  final String productId;

  @override
  List<Object?> get props => [productId];
}

class ProductDetailQuantityIncremented extends ProductDetailEvent {
  const ProductDetailQuantityIncremented();
}

class ProductDetailQuantityDecremented extends ProductDetailEvent {
  const ProductDetailQuantityDecremented();
}
