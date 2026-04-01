import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';

sealed class ProductFormState extends Equatable {
  const ProductFormState();
  @override
  List<Object?> get props => [];
}

class ProductFormInitial extends ProductFormState {
  const ProductFormInitial();
}

class ProductFormLoading extends ProductFormState {
  const ProductFormLoading();
}

class ProductFormReady extends ProductFormState {
  const ProductFormReady({this.product});
  final InventoryProduct? product;
  @override
  List<Object?> get props => [product];
}

class ProductFormSuccess extends ProductFormState {
  const ProductFormSuccess();
}

class ProductFormFailure extends ProductFormState {
  const ProductFormFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
