import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/product_detail/domain/entities/product_detail.dart';

sealed class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

class ProductDetailLoaded extends ProductDetailState {
  const ProductDetailLoaded({required this.product, this.quantity = 1});

  final ProductDetail product;
  final int quantity;

  ProductDetailLoaded copyWith({int? quantity}) => ProductDetailLoaded(
    product: product,
    quantity: quantity ?? this.quantity,
  );

  @override
  List<Object?> get props => [product, quantity];
}

class ProductDetailFailure extends ProductDetailState {
  const ProductDetailFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
