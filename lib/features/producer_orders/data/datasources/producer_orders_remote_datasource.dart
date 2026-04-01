import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_item.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

@lazySingleton
class ProducerOrdersRemoteDataSource {
  static final List<ProducerOrder> _mockOrders = [
    ProducerOrder(
      id: 'po001',
      consumerName: 'João Silva',
      consumerAvatarUrl: '',
      consumerSince: 'Janeiro de 2025',
      status: ProducerOrderStatus.pending,
      totalPrice: 47.80,
      deliveryAddress: 'Rua das Flores, 123',
      deliveryNeighborhood: 'Bairro Jardim',
      deliveryCityState: 'Porto Alegre, RS',
      deliveryComplement: 'Apto 42',
      items: const [
        ProducerOrderItem(
          productId: 'p001',
          name: 'Tomate Cereja Orgânico',
          imageUrl: '',
          unitPrice: 2.50,
          totalPrice: 25.00,
          quantity: 10,
          unityType: 'kg',
        ),
        ProducerOrderItem(
          productId: 'p002',
          name: 'Couve Manteiga',
          imageUrl: '',
          unitPrice: 4.90,
          totalPrice: 14.70,
          quantity: 3,
          unityType: 'maço',
        ),
        ProducerOrderItem(
          productId: 'p003',
          name: 'Batata Monalisa',
          imageUrl: '',
          unitPrice: 8.20,
          totalPrice: 8.20,
          quantity: 1,
          unityType: 'kg',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isNew: true,
      consumerPhone: '51999990001',
    ),
    ProducerOrder(
      id: 'po002',
      consumerName: 'Maria Costa',
      consumerAvatarUrl: '',
      consumerSince: 'Março de 2024',
      status: ProducerOrderStatus.accepted,
      totalPrice: 32.60,
      deliveryAddress: 'Av. Independência, 456',
      deliveryNeighborhood: 'Bom Fim',
      deliveryCityState: 'Porto Alegre, RS',
      deliveryComplement: '',
      items: const [
        ProducerOrderItem(
          productId: 'p001',
          name: 'Tomate Cereja Orgânico',
          imageUrl: '',
          unitPrice: 2.50,
          totalPrice: 12.50,
          quantity: 5,
          unityType: 'kg',
        ),
        ProducerOrderItem(
          productId: 'p002',
          name: 'Couve Manteiga',
          imageUrl: '',
          unitPrice: 4.90,
          totalPrice: 9.80,
          quantity: 2,
          unityType: 'maço',
        ),
        ProducerOrderItem(
          productId: 'p003',
          name: 'Batata Monalisa',
          imageUrl: '',
          unitPrice: 8.20,
          totalPrice: 8.20,
          quantity: 1,
          unityType: 'kg',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isNew: false,
      consumerPhone: '51999990002',
    ),
    ProducerOrder(
      id: 'po003',
      consumerName: 'Carlos Mendes',
      consumerAvatarUrl: '',
      consumerSince: 'Junho de 2024',
      status: ProducerOrderStatus.inDelivery,
      totalPrice: 19.60,
      deliveryAddress: 'Rua Osvaldo Aranha, 789',
      deliveryNeighborhood: 'Bom Fim',
      deliveryCityState: 'Porto Alegre, RS',
      deliveryComplement: 'Casa 2',
      items: const [
        ProducerOrderItem(
          productId: 'p002',
          name: 'Couve Manteiga',
          imageUrl: '',
          unitPrice: 4.90,
          totalPrice: 9.80,
          quantity: 2,
          unityType: 'maço',
        ),
        ProducerOrderItem(
          productId: 'p003',
          name: 'Batata Monalisa',
          imageUrl: '',
          unitPrice: 8.20,
          totalPrice: 8.20,
          quantity: 1,
          unityType: 'kg',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isNew: false,
      consumerPhone: '51999990003',
    ),
    ProducerOrder(
      id: 'po004',
      consumerName: 'Ana Souza',
      consumerAvatarUrl: '',
      consumerSince: 'Novembro de 2023',
      status: ProducerOrderStatus.delivered,
      totalPrice: 56.40,
      deliveryAddress: 'Rua 24 de Outubro, 200',
      deliveryNeighborhood: 'Moinhos de Vento',
      deliveryCityState: 'Porto Alegre, RS',
      deliveryComplement: 'Apto 301',
      items: const [
        ProducerOrderItem(
          productId: 'p001',
          name: 'Tomate Cereja Orgânico',
          imageUrl: '',
          unitPrice: 2.50,
          totalPrice: 25.00,
          quantity: 10,
          unityType: 'kg',
        ),
        ProducerOrderItem(
          productId: 'p002',
          name: 'Couve Manteiga',
          imageUrl: '',
          unitPrice: 4.90,
          totalPrice: 24.50,
          quantity: 5,
          unityType: 'maço',
        ),
        ProducerOrderItem(
          productId: 'p003',
          name: 'Batata Monalisa',
          imageUrl: '',
          unitPrice: 8.20,
          totalPrice: 8.20,
          quantity: 1,
          unityType: 'kg',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 24)),
      isNew: false,
      consumerPhone: '51999990004',
    ),
  ];

  /// Gets producer orders, optionally filtered by [status].
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<List<ProducerOrder>> getOrders({ProducerOrderStatus? status}) async {
  ///   try {
  ///     final response = await _apiClient.dio.get<Map<String, dynamic>>(
  ///       ApiEndpoints.producerOrders,
  ///       queryParameters: {
  ///         if (status != null) 'status': status.name,
  ///       },
  ///     );
  ///     return (response.data!['data'] as List)
  ///         .map((e) => ProducerOrder.fromJson(e as Map<String, dynamic>))
  ///         .toList();
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<List<ProducerOrder>> getOrders({ProducerOrderStatus? status}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (status == null) return List.from(_mockOrders);
    return _mockOrders.where((o) => o.status == status).toList();
  }

  /// Gets a single producer order by [id].
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<ProducerOrder> getOrderById(String id) async {
  ///   try {
  ///     final response = await _apiClient.dio.get<Map<String, dynamic>>(
  ///       '${ApiEndpoints.producerOrders}/$id',
  ///     );
  ///     return ProducerOrder.fromJson(response.data!);
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<ProducerOrder> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockOrders.firstWhere((o) => o.id == id);
  }

  /// Confirms a producer order (accept it).
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<void> confirmOrder(String id) async {
  ///   try {
  ///     await _apiClient.dio.post<void>(
  ///       ApiEndpoints.producerOrderConfirm(id),
  ///     );
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<void> confirmOrder(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _mockOrders.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      _mockOrders[idx] = _mockOrders[idx].copyWith(
        status: ProducerOrderStatus.accepted,
        isNew: false,
      );
    }
  }

  /// Refuses/cancels a producer order.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<void> refuseOrder(String id) async {
  ///   try {
  ///     await _apiClient.dio.post<void>(
  ///       ApiEndpoints.producerOrderCancel(id),
  ///     );
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<void> refuseOrder(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _mockOrders.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      _mockOrders[idx] = _mockOrders[idx].copyWith(
        status: ProducerOrderStatus.cancelled,
      );
    }
  }

  /// Updates the status of a producer order.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<void> updateStatus(String id, ProducerOrderStatus status) async {
  ///   try {
  ///     await _apiClient.dio.patch<void>(
  ///       ApiEndpoints.producerOrderStatus(id),
  ///       data: {'status': status.name},
  ///     );
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<void> updateStatus(String id, ProducerOrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _mockOrders.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      _mockOrders[idx] = _mockOrders[idx].copyWith(status: status);
    }
  }
}
