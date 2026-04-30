import 'package:equatable/equatable.dart';

sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class ProductDetailStarted extends ProductDetailEvent {
  const ProductDetailStarted(this.productId, {this.producerId = ''});
  final String productId;
  final String producerId;

  @override
  List<Object?> get props => [productId, producerId];
}

class ProductDetailQuantityIncremented extends ProductDetailEvent {
  const ProductDetailQuantityIncremented();
}

class ProductDetailQuantityDecremented extends ProductDetailEvent {
  const ProductDetailQuantityDecremented();
}
