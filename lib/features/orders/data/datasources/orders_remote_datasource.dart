import 'package:injectable/injectable.dart' hide Order;
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_item.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';

@lazySingleton
class OrdersRemoteDatasource {
  static final List<Order> _mockOrders = [
    Order(
      id: '4829',
      producerId: 'p1',
      farmName: 'Fazenda Sol Nascente',
      farmAvatarUrl: '',
      ownerName: 'Manoel Silva',
      items: const [
        OrderItem(
          productId: 'prod1',
          name: 'Tomate',
          imageUrl: '',
          quantity: 1,
          unityType: 'un',
          totalPrice: 12.90,
        ),
        OrderItem(
          productId: 'prod2',
          name: 'Bananas',
          imageUrl: '',
          quantity: 3,
          unityType: 'kg',
          totalPrice: 18,
        ),
        OrderItem(
          productId: 'prod3',
          name: 'Maçã',
          imageUrl: '',
          quantity: 1,
          unityType: 'kg',
          totalPrice: 9,
        ),
        OrderItem(
          productId: 'prod4',
          name: 'Alface Crespa',
          imageUrl: '',
          quantity: 1,
          unityType: 'un',
          totalPrice: 4.50,
        ),
      ],
      totalAmount: 145.90,
      status: OrderStatus.pending,
      createdAt: DateTime(2026, 1, 21, 21, 8),
      deliveryAddress: const DeliveryAddress(
        street: 'Rua das Flores, 123 - Apto 42',
        neighborhood: 'Bairro Primavera',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      bankInfo: const ProducerBankInfo(
        bank: 'Nubank (260)',
        agency: '0001',
        account: '12345-6',
        pixKey: 'fazenda.boavista@email.com',
      ),
    ),
    Order(
      id: '4828',
      producerId: 'p1',
      farmName: 'Fazenda Sol Nascente',
      farmAvatarUrl: '',
      ownerName: 'Manoel Silva',
      items: const [
        OrderItem(
          productId: 'prod1',
          name: 'Tomate',
          imageUrl: '',
          quantity: 1,
          unityType: 'un',
          totalPrice: 12.90,
        ),
        OrderItem(
          productId: 'prod2',
          name: 'Bananas',
          imageUrl: '',
          quantity: 3,
          unityType: 'kg',
          totalPrice: 18,
        ),
        OrderItem(
          productId: 'prod3',
          name: 'Maçã',
          imageUrl: '',
          quantity: 1,
          unityType: 'kg',
          totalPrice: 9,
        ),
      ],
      totalAmount: 145.90,
      status: OrderStatus.accepted,
      createdAt: DateTime(2026, 1, 21, 21, 8),
      deliveryAddress: const DeliveryAddress(
        street: 'Rua das Flores, 123 - Apto 42',
        neighborhood: 'Bairro Primavera',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      bankInfo: const ProducerBankInfo(
        bank: 'Nubank (260)',
        agency: '0001',
        account: '12345-6',
        pixKey: 'fazenda.boavista@email.com',
      ),
    ),
    Order(
      id: '4827',
      producerId: 'p1',
      farmName: 'Fazenda Sol Nascente',
      farmAvatarUrl: '',
      ownerName: 'Manoel Silva',
      items: const [
        OrderItem(
          productId: 'prod1',
          name: 'Tomate',
          imageUrl: '',
          quantity: 1,
          unityType: 'un',
          totalPrice: 12.90,
        ),
        OrderItem(
          productId: 'prod5',
          name: 'Maçã',
          imageUrl: '',
          quantity: 1,
          unityType: 'kg',
          totalPrice: 9,
        ),
      ],
      totalAmount: 145.90,
      status: OrderStatus.delivered,
      createdAt: DateTime(2026, 1, 21, 21, 8),
      deliveryAddress: const DeliveryAddress(
        street: 'Rua das Flores, 123 - Apto 42',
        neighborhood: 'Bairro Primavera',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      bankInfo: const ProducerBankInfo(
        bank: 'Nubank (260)',
        agency: '0001',
        account: '12345-6',
        pixKey: 'fazenda.boavista@email.com',
      ),
    ),
    Order(
      id: '4826',
      producerId: 'p1',
      farmName: 'Fazenda Sol Nascente',
      farmAvatarUrl: '',
      ownerName: 'Manoel Silva',
      items: const [
        OrderItem(
          productId: 'prod2',
          name: 'Bananas',
          imageUrl: '',
          quantity: 3,
          unityType: 'kg',
          totalPrice: 18,
        ),
      ],
      totalAmount: 145.90,
      status: OrderStatus.cancelled,
      createdAt: DateTime(2026, 1, 21, 21, 8),
      deliveryAddress: const DeliveryAddress(
        street: 'Rua das Flores, 123 - Apto 42',
        neighborhood: 'Bairro Primavera',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-100',
      ),
      bankInfo: const ProducerBankInfo(
        bank: 'Nubank (260)',
        agency: '0001',
        account: '12345-6',
        pixKey: 'fazenda.boavista@email.com',
      ),
    ),
  ];

  /// Gets consumer orders, optionally filtered by [status].
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future`<List<Order>>` getOrders({OrderStatus? status}) async {
  ///   try {
  ///     final response = await _apiClient.dio.get`<Map<String, dynamic>>`(
  ///       ApiEndpoints.orders,
  ///       queryParameters: {
  ///         if (status != null) 'status': status.name,
  ///       },
  ///     );
  ///     return (response.data!['data'] as List)
  ///         .map((e) => Order.fromJson(e as `Map<String, dynamic>`))
  ///         .toList();
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<List<Order>> getOrders({OrderStatus? status}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (status == null) return List.from(_mockOrders);
    return _mockOrders.where((o) => o.status == status).toList();
  }

  /// Gets a single order by [id].
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future`<Order>` getOrderById(String id) async {
  ///   try {
  ///     final response = await _apiClient.dio.get`<Map<String, dynamic>>`(
  ///       ApiEndpoints.order(id),
  ///     );
  ///     return Order.fromJson(response.data!);
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<Order> getOrderById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _mockOrders.firstWhere(
      (o) => o.id == id,
      orElse: () => _mockOrders.first,
    );
  }

  /// Confirms an order from cart (POST /orders).
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future`<Order>` confirmOrder(String cartId) async {
  ///   try {
  ///     final response = await _apiClient.dio.post`<Map<String, dynamic>>`(
  ///       ApiEndpoints.orders,
  ///       data: {'cart_id': cartId},
  ///     );
  ///     return Order.fromJson(response.data!);
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<Order> confirmOrder(String cartId) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return _mockOrders.first;
  }

  /// Rates a producer for a completed order.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future`<void>` rateProducer(String orderId, int rating) async {
  ///   try {
  ///     await _apiClient.dio.post`<void>`(
  ///       ApiEndpoints.orderRating(orderId),
  ///       data: {'rating': rating},
  ///     );
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<void> rateProducer(String orderId, int rating) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}
