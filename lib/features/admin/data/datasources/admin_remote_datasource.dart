import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer_summary.dart';

@lazySingleton
class AdminRemoteDataSource {
  static final _baseDate = DateTime(2026, 3, 24);

  // Mock interno com dados completos — usado por getProducerById e updateProducer.
  // getProducers() deriva o sumário a partir desta lista.
  static final List<AdminProducer> _mockProducers = [
    AdminProducer(
      id: 'ap001',
      name: 'Ricardo Oliveira',
      email: 'ricardo.oliveira@ragro.com.br',
      phone: '(51) 99111-0001',
      fiscalNumber: '11122233344',
      fiscalNumberType: 'CPF',
      zipCode: '90010120',
      street: 'Rua das Flores, 123',
      neighborhood: 'Centro',
      city: 'Porto Alegre',
      state: 'RS',
      bankName: 'Banco do Brasil',
      agency: '3452-X',
      accountNumber: '111111-1',
      holderName: 'Ricardo Oliveira',
      scheduleWeekdays: [true, true, true, true, true, false, false],
      scheduleStart: '08:00',
      scheduleEnd: '18:00',
      createdAt: _baseDate,
      updatedAt: _baseDate,
      active: true,
    ),
    AdminProducer(
      id: 'ap002',
      name: 'Matheus Silva',
      email: 'matheus.silva@ragro.com.br',
      phone: '(51) 99111-0002',
      fiscalNumber: '22233344455',
      fiscalNumberType: 'CPF',
      zipCode: '90035070',
      street: 'Av. Independência, 456',
      neighborhood: 'Independência',
      city: 'Porto Alegre',
      state: 'RS',
      bankName: 'Itaú',
      agency: '1234',
      accountNumber: '222222-2',
      holderName: 'Matheus Silva',
      scheduleWeekdays: [true, true, true, true, true, true, false],
      scheduleStart: '07:00',
      scheduleEnd: '17:00',
      createdAt: _baseDate,
      updatedAt: _baseDate,
      active: true,
    ),
    AdminProducer(
      id: 'ap003',
      name: 'Giovana Duarte',
      email: 'giovana.duarte@ragro.com.br',
      phone: '(51) 99111-0003',
      fiscalNumber: '33344455566',
      fiscalNumberType: 'CPF',
      zipCode: '90040060',
      street: 'Rua Osvaldo Aranha, 789',
      neighborhood: 'Bom Fim',
      city: 'Porto Alegre',
      state: 'RS',
      bankName: 'Bradesco',
      agency: '5678',
      accountNumber: '333333-3',
      holderName: 'Giovana Duarte',
      scheduleWeekdays: [false, true, true, true, true, false, false],
      scheduleStart: '09:00',
      scheduleEnd: '19:00',
      createdAt: _baseDate,
      updatedAt: _baseDate,
      active: true,
    ),
    AdminProducer(
      id: 'ap004',
      name: 'Antônio Madeira',
      email: 'antonio.madeira@ragro.com.br',
      phone: '(51) 99111-0004',
      fiscalNumber: '44455566677',
      fiscalNumberType: 'CPF',
      zipCode: '90510001',
      street: 'Rua 24 de Outubro, 200',
      neighborhood: 'Moinhos de Vento',
      city: 'Porto Alegre',
      state: 'RS',
      bankName: 'Nubank',
      agency: '0001',
      accountNumber: '444444-4',
      holderName: 'Antônio Madeira',
      scheduleWeekdays: [true, true, true, true, true, true, true],
      scheduleStart: '06:00',
      scheduleEnd: '20:00',
      createdAt: _baseDate,
      updatedAt: _baseDate,
      active: true,
    ),
  ];

  /// Gets all producers for admin management (summary fields only).
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<List<AdminProducerSummary>> getProducers() async {
  ///   try {
  ///     final response = await _apiClient.dio.get<Map<String, dynamic>>(
  ///       ApiEndpoints.adminProducers,
  ///     );
  ///     return (response.data!['content'] as List)
  ///         .map((e) => AdminProducerSummaryModel.fromJson(e as Map<String, dynamic>))
  ///         .toList();
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<List<AdminProducerSummary>> getProducers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockProducers
        .map((p) => AdminProducerSummary(
              id: p.id,
              name: p.name,
              email: p.email,
              phone: p.phone,
              address: p.address,
              active: p.active,
              createdAt: p.createdAt,
              updatedAt: p.updatedAt,
            ))
        .toList();
  }

  /// Gets a single producer by ID with full detail fields.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<AdminProducer> getProducerById(String id) async {
  ///   try {
  ///     final response = await _apiClient.dio.get<Map<String, dynamic>>(
  ///       ApiEndpoints.adminProducer(id),
  ///     );
  ///     return AdminProducerModel.fromJson(response.data!);
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<AdminProducer> getProducerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockProducers.firstWhere((p) => p.id == id);
  }

  /// Creates a new producer account.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<void> createProducer(AdminProducer producer, String password) async {
  ///   try {
  ///     final model = AdminProducerModel.fromEntity(producer);
  ///     await _apiClient.dio.post<void>(
  ///       ApiEndpoints.adminProducers,
  ///       data: {...model.toJson(), 'password': password},
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

  /// Updates an existing producer account.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<void> updateProducer(AdminProducer producer) async {
  ///   try {
  ///     final model = AdminProducerModel.fromEntity(producer);
  ///     await _apiClient.dio.put<void>(
  ///       ApiEndpoints.adminProducer(producer.id),
  ///       data: model.toJson(),
  ///     );
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<void> updateProducer(AdminProducer producer) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _mockProducers.indexWhere((p) => p.id == producer.id);
    if (idx >= 0) {
      _mockProducers[idx] = producer.copyWith(updatedAt: DateTime.now());
    }
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
