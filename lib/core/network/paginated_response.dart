// lib/core/network/paginated_response.dart

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      content:
          (json['content'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e as Map<String, dynamic>))
              .toList() ??
          [],
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  PaginatedResponse<R> map<R>(R Function(T) mapper) {
    return PaginatedResponse<R>(
      content: content.map(mapper).toList(),
      page: page,
      size: size,
      totalElements: totalElements,
      totalPages: totalPages,
    );
  }
}
