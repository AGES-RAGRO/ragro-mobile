import 'package:equatable/equatable.dart';

enum SearchResultType { producer, product }

class SearchResult extends Equatable {
  const SearchResult({
    required this.id,
    required this.type,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    this.price,
    this.rating,
    this.category,
  });

  final String id;
  final SearchResultType type;
  final String name;
  final String subtitle;
  final String imageUrl;
  final double? price;
  final double? rating;
  final String? category;

  @override
  List<Object?> get props => [id, type, name, subtitle, imageUrl, price, rating, category];
}
