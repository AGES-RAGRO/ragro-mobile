import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

sealed class ProductFormEvent extends Equatable {
  const ProductFormEvent();
  @override
  List<Object?> get props => [];
}

class ProductFormStarted extends ProductFormEvent {
  const ProductFormStarted({this.productId});
  final String? productId;
  @override
  List<Object?> get props => [productId];
}

class ProductFormSaved extends ProductFormEvent {
  const ProductFormSaved({
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stock,
    this.photo,
  });

  final String name;
  final String description;
  final double price;
  final String unit;
  final double stock;
  final XFile? photo;

  @override
  List<Object?> get props => [name, description, price, unit, stock, photo];
}

class ProductFormPhotoPicked extends ProductFormEvent {
  const ProductFormPhotoPicked(this.photo);
  final XFile photo;
  @override
  List<Object?> get props => [photo];
}
