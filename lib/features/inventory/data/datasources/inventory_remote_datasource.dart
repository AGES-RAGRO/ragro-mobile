import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';

@lazySingleton
class InventoryRemoteDataSource {
  static final List<InventoryProduct> _mockProducts = [
    const InventoryProduct(
      id: 'inv001',
      producerId: 'prod001',
      name: 'Tomate Cereja Orgânico',
      description:
          'Tomate cereja cultivado sem agrotóxicos, colhido fresco da horta.',
      imageUrl: '',
      price: 2.50,
      unit: 'kg',
      stock: 32,
      active: true,
    ),
    const InventoryProduct(
      id: 'inv002',
      producerId: 'prod001',
      name: 'Couve Manteiga',
      description: 'Couve fresca e crocante, ideal para refogados e saladas.',
      imageUrl: '',
      price: 4.90,
      unit: 'maço',
      stock: 32,
      active: true,
    ),
    const InventoryProduct(
      id: 'inv003',
      producerId: 'prod001',
      name: 'Batata Monalisa',
      description:
          'Batata de casca fina e polpa macia, perfeita para purês e cozidos.',
      imageUrl: '',
      price: 8.20,
      unit: 'kg',
      stock: 0,
      active: false,
    ),
  ];

  /// Gets all products for the authenticated producer.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future`<List<InventoryProduct>>` getProducts() async {
  ///   try {
  ///     // Producer ID is derived from the auth token on the backend.
  ///     final response = await _apiClient.dio.get`<Map<String, dynamic>>`(
  ///       ApiEndpoints.products,
  ///       queryParameters: {'producer_id': 'me'},
  ///     );
  ///     return (response.data!['data'] as List)
  ///         .map((e) => InventoryProduct.fromJson(e as `Map<String, dynamic>`))
  ///         .toList();
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<List<InventoryProduct>> getProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List.from(_mockProducts);
  }

  /// Creates a new product in the inventory.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future`<void>` createProduct(InventoryProduct product) async {
  ///   try {
  ///     await _apiClient.dio.post`<void>`(
  ///       ApiEndpoints.products,
  ///       data: product.toJson(),
  ///     );
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<void> createProduct(InventoryProduct product) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _mockProducts.add(product);
  }

  /// Updates an existing product.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future`<void>` updateProduct(InventoryProduct product) async {
  ///   try {
  ///     await _apiClient.dio.put`<void>`(
  ///       ApiEndpoints.product(product.id),
  ///       data: product.toJson(),
  ///     );
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<void> updateProduct(InventoryProduct product) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final idx = _mockProducts.indexWhere((p) => p.id == product.id);
    if (idx >= 0) _mockProducts[idx] = product;
  }

  /// Deletes a product by [id].
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future`<void>` deleteProduct(String id) async {
  ///   try {
  ///     await _apiClient.dio.delete`<void>`(
  ///       ApiEndpoints.product(id),
  ///     );
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<void> deleteProduct(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _mockProducts.removeWhere((p) => p.id == id);
  }
}
