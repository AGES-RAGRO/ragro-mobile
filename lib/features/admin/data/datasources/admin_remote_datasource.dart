import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';

@lazySingleton
class AdminRemoteDataSource {
  static final _baseDate = DateTime(2026, 3, 24);

  static final List<AdminProducer> _mockProducers = [
    AdminProducer(
      id: 'ap001',
      name: 'Ricardo Oliveira',
      email: 'ricardo.oliveira@ragro.com.br',
      location: 'Porto Alegre, RS',
      address: 'Rua das Flores, 123, Porto Alegre, RS',
      createdAt: _baseDate,
      updatedAt: _baseDate,
      active: true,
    ),
    AdminProducer(
      id: 'ap002',
      name: 'Matheus Silva',
      email: 'matheus.silva@ragro.com.br',
      location: 'Porto Alegre, RS',
      address: 'Av. Independência, 456, Porto Alegre, RS',
      createdAt: _baseDate,
      updatedAt: _baseDate,
      active: true,
    ),
    AdminProducer(
      id: 'ap003',
      name: 'Giovana Duarte',
      email: 'giovana.duarte@ragro.com.br',
      location: 'Porto Alegre, RS',
      address: 'Rua Osvaldo Aranha, 789, Porto Alegre, RS',
      createdAt: _baseDate,
      updatedAt: _baseDate,
      active: true,
    ),
    AdminProducer(
      id: 'ap004',
      name: 'Antônio Madeira',
      email: 'antonio.madeira@ragro.com.br',
      location: 'Porto Alegre, RS',
      address: 'Rua 24 de Outubro, 200, Porto Alegre, RS',
      createdAt: _baseDate,
      updatedAt: _baseDate,
      active: true,
    ),
  ];

  /// Gets all producers for admin management.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<List<AdminProducer>> getProducers() async {
  ///   try {
  ///     final response = await _apiClient.dio.get<Map<String, dynamic>>(
  ///       ApiEndpoints.adminProducers,
  ///     );
  ///     return (response.data!['data'] as List)
  ///         .map((e) => AdminProducer.fromJson(e as Map<String, dynamic>))
  ///         .toList();
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<List<AdminProducer>> getProducers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_mockProducers);
  }

  /// Creates a new producer account.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<void> createProducer(AdminProducer producer, String password) async {
  ///   try {
  ///     await _apiClient.dio.post<void>(
  ///       ApiEndpoints.adminProducers,
  ///       data: {
  ///         ...producer.toJson(),
  ///         'password': password,
  ///       },
  ///     );
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<void> createProducer(AdminProducer producer, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _mockProducers.add(producer);
  }

  /// Deactivates a producer account.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<void> deactivateProducer(String id) async {
  ///   try {
  ///     await _apiClient.dio.patch<void>(
  ///       '${ApiEndpoints.adminProducer(id)}/deactivate',
  ///     );
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<void> deactivateProducer(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _mockProducers.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      _mockProducers[idx] = _mockProducers[idx].copyWith(active: false);
    }
  }

  /// Activates a previously deactivated producer account.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<void> activateProducer(String id) async {
  ///   try {
  ///     await _apiClient.dio.patch<void>(
  ///       '${ApiEndpoints.adminProducer(id)}/activate',
  ///     );
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<void> activateProducer(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _mockProducers.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      _mockProducers[idx] = _mockProducers[idx].copyWith(active: true);
    }
  }
}
