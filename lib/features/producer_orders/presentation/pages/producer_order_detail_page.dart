// Producer Order Detail screen (US-21). Route: GET /orders/producer/:id.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/formatters/currency.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_item.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_order_detail_bloc.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_order_detail_event.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_order_detail_state.dart';
import 'package:ragro_mobile/shared/utils/unity_type_label.dart';
import 'package:ragro_mobile/shared/widgets/cancel_order_dialog.dart';
import 'package:ragro_mobile/shared/widgets/order_detail/cancellation_card.dart';
import 'package:ragro_mobile/shared/widgets/order_detail/delivery_address_card.dart';
import 'package:ragro_mobile/shared/widgets/order_detail/order_action_button.dart';
import 'package:ragro_mobile/shared/widgets/order_detail/order_action_footer.dart';
import 'package:ragro_mobile/shared/widgets/order_detail/order_item_row.dart';
import 'package:ragro_mobile/shared/widgets/order_detail/order_items_card.dart';
import 'package:ragro_mobile/shared/widgets/order_detail/order_section_title.dart';
import 'package:ragro_mobile/shared/widgets/order_detail/order_status_badge.dart';
import 'package:ragro_mobile/shared/widgets/order_detail/order_success_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ProducerOrderDetailPage extends StatelessWidget {
  const ProducerOrderDetailPage({
    required this.orderId,
    this.initialOrder,
    super.key,
  });

  final String orderId;
  final ProducerOrder? initialOrder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProducerOrderDetailBloc>()
        ..add(ProducerOrderDetailStarted(orderId, initialOrder: initialOrder)),
      child: BlocConsumer<ProducerOrderDetailBloc, ProducerOrderDetailState>(
        listener: (context, state) async {
          if (state is ProducerOrderDetailActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          } else if (state is ProducerOrderDetailSuccess) {
            if (state.action == 'refused') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pedido cancelado com sucesso.'),
                  backgroundColor: Colors.black87,
                ),
              );
              if (context.mounted) context.pop('cancelled');
            } else if (state.action == 'confirmed') {
              await OrderSuccessDialog.show(
                context,
                icon: Icons.check_circle_outline,
                title: 'Pedido confirmado\ncom sucesso!',
                description: 'O pedido foi aceito e está em andamento.',
              );
            } else if (state.action == 'status_updated') {
              if (state.order.status == ProducerOrderStatus.inDelivery) {
                await OrderSuccessDialog.show(
                  context,
                  icon: Icons.local_shipping_outlined,
                  title: 'Entrega iniciada\ncom sucesso!',
                  description: 'Você iniciou a entrega do pedido. Boa entrega!',
                );
                if (context.mounted) context.pop('in_delivery');
              } else if (state.order.status == ProducerOrderStatus.delivered) {
                await OrderSuccessDialog.show(
                  context,
                  icon: Icons.check_circle_outline,
                  title: 'Entrega confirmada\ncom sucesso!',
                  description:
                      'O pedido foi entregue ao cliente e está concluído.',
                );
                if (context.mounted) context.pop('delivered');
              }
            }
          }
        },
        builder: (context, state) {
          if (state is ProducerOrderDetailLoading ||
              state is ProducerOrderDetailInitial) {
            return const Scaffold(
              body: Center(child: Text('Carregando detalhes do pedido...')),
            );
          }
          if (state is ProducerOrderDetailFailure) {
            return _ProducerOrderErrorView(
              orderId: orderId,
              message: state.message,
            );
          }

          final order = switch (state) {
            ProducerOrderDetailLoaded(:final order) => order,
            ProducerOrderDetailConfirming(:final order) => order,
            ProducerOrderDetailRefusing(:final order) => order,
            ProducerOrderDetailUpdatingStatus(:final order) => order,
            ProducerOrderDetailSuccess(:final order) => order,
            ProducerOrderDetailActionError(:final order) => order,
            _ => null,
          };
          if (order == null) return const Scaffold();

          final isProcessing =
              state is ProducerOrderDetailConfirming ||
              state is ProducerOrderDetailRefusing ||
              state is ProducerOrderDetailUpdatingStatus;

          return WillPopScope(
            onWillPop: () async {
              // Mirrors the header back button: signal 'cancelled' so the list
              // moves the order to the Cancelled tab after a refuse, 'seen' if
              // the order was new, otherwise nothing.
              if (order.status == ProducerOrderStatus.cancelled) {
                context.pop('cancelled');
              } else if (order.isNew) {
                context.pop('seen');
              } else {
                context.pop();
              }
              return false;
            },
            child: _ProducerOrderDetailView(
              order: order,
              isProcessing: isProcessing,
            ),
          );
        },
      ),
    );
  }
}

class _ProducerOrderErrorView extends StatelessWidget {
  const _ProducerOrderErrorView({required this.orderId, required this.message});

  final String orderId;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 56,
                  color: AppColors.placeholder,
                ),
                const SizedBox(height: 16),
                Text(
                  message.toLowerCase().contains('404')
                      ? 'Pedido não encontrado.'
                      : 'Não foi possível carregar os detalhes do pedido.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<ProducerOrderDetailBloc>().add(
                    ProducerOrderDetailStarted(orderId),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProducerOrderDetailView extends StatelessWidget {
  const _ProducerOrderDetailView({
    required this.order,
    required this.isProcessing,
  });

  final ProducerOrder order;
  final bool isProcessing;

  String _itemQuantityLabel(ProducerOrderItem item) {
    final value = item.quantity % 1 == 0
        ? item.quantity.toInt().toString()
        : item.quantity.toStringAsFixed(2).replaceAll('.', ',');
    return 'Qtd: $value ${localizeUnityType(item.unityType)}';
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProducerOrderDetailBloc>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 190),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(order: order),
                  _CustomerHeader(order: order),
                  const OrderSectionTitle('ITENS DO PEDIDO'),
                  OrderItemsCard(
                    totalLabel: formatCurrency(order.totalPrice),
                    items: [
                      for (final item in order.items)
                        OrderItemRow(
                          name: item.name,
                          photoUrl: item.imageUrl,
                          quantityLabel: _itemQuantityLabel(item),
                          unitPriceLabel: formatCurrency(item.unitPrice),
                          subtotalLabel: formatCurrency(item.totalPrice),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const OrderSectionTitle('ENTREGA'),
                  DeliveryAddressCard(
                    lines: [
                      order.deliveryAddress,
                      [
                        order.deliveryNeighborhood,
                        order.deliveryCityState,
                      ].where((line) => line.isNotEmpty).join(', '),
                      order.deliveryComplement,
                    ],
                  ),
                  if (order.status == ProducerOrderStatus.cancelled &&
                      order.cancellationReason != null) ...[
                    const SizedBox(height: 18),
                    const OrderSectionTitle('CANCELAMENTO'),
                    CancellationCard.producer(
                      reason: order.cancellationReason ?? '',
                      details: order.cancellationDetails,
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _ActionFooter(
                order: order,
                isProcessing: isProcessing,
                bloc: bloc,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.order});

  final ProducerOrder order;

  @override
  Widget build(BuildContext context) {
    final displayId =
        '#${order.id.length > 4 ? order.id.substring(0, 4) : order.id}';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (order.status == ProducerOrderStatus.cancelled) {
                context.pop('cancelled');
              } else if (order.isNew) {
                context.pop('seen');
              } else {
                context.pop();
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalhes do Pedido',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  displayId,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.placeholder,
                  ),
                ),
              ],
            ),
          ),
          OrderStatusBadge(status: order.status.apiValue),
        ],
      ),
    );
  }
}

class _CustomerHeader extends StatelessWidget {
  const _CustomerHeader({required this.order});

  final ProducerOrder order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.darkGreen.withValues(alpha: 0.1),
            backgroundImage: order.consumerAvatarUrl.isNotEmpty
                ? NetworkImage(order.consumerAvatarUrl)
                : null,
            child: order.consumerAvatarUrl.isEmpty
                ? Text(
                    order.consumerName.isNotEmpty ? order.consumerName[0] : '?',
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.darkGreen,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.consumerName,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  order.consumerSince.isEmpty
                      ? DateFormat(
                          'dd/MM/yyyy, HH:mm',
                          'pt_BR',
                        ).format(order.createdAt)
                      : 'Cliente desde ${order.consumerSince}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: AppColors.placeholder,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionFooter extends StatelessWidget {
  const _ActionFooter({
    required this.order,
    required this.isProcessing,
    required this.bloc,
  });

  final ProducerOrder order;
  final bool isProcessing;
  final ProducerOrderDetailBloc bloc;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      if (order.status == ProducerOrderStatus.pending)
        Row(
          children: [
            Expanded(
              child: OrderActionButton(
                label: 'Recusar pedido',
                icon: Icons.cancel_outlined,
                color: AppColors.red,
                onTap: isProcessing ? null : () => _confirmRefuse(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OrderActionButton(
                label: 'Confirmar Pedido',
                icon: Icons.check_circle_outline,
                color: AppColors.darkGreen,
                onTap: isProcessing
                    ? null
                    : () => bloc.add(ProducerOrderDetailConfirmed(order.id)),
              ),
            ),
          ],
        ),
      if (order.status == ProducerOrderStatus.accepted)
        OrderActionButton(
          label: 'Cancelar Pedido',
          icon: Icons.cancel_outlined,
          color: AppColors.red,
          onTap: isProcessing ? null : () => _confirmRefuse(context),
        ),
      if (order.status == ProducerOrderStatus.inDelivery)
        Row(
          children: [
            Expanded(
              child: OrderActionButton(
                label: 'Cancelar Pedido',
                icon: Icons.cancel_outlined,
                color: AppColors.red,
                onTap: isProcessing ? null : () => _confirmRefuse(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OrderActionButton(
                label: 'Entregue',
                icon: Icons.check_circle_outline,
                color: AppColors.darkGreen,
                onTap: isProcessing
                    ? null
                    : () => bloc.add(
                        ProducerOrderDetailStatusUpdated(
                          order.id,
                          ProducerOrderStatus.delivered,
                        ),
                      ),
              ),
            ),
          ],
        ),
      if (order.consumerPhone.isNotEmpty)
        OrderActionButton(
          label: 'Contatar Cliente',
          icon: Icons.chat,
          color: const Color(0xFF25D366),
          onTap: isProcessing ? null : () => _contactCustomer(context),
        ),
    ];

    return OrderActionFooter(isBusy: isProcessing, buttons: buttons);
  }

  Future<void> _confirmRefuse(BuildContext context) async {
    final cancelResult = await CancelOrderDialog.showForProducer(context);
    if (cancelResult == null) return;
    bloc.add(
      ProducerOrderDetailRefused(
        order.id,
        reason: cancelResult.reason,
        details: cancelResult.details,
      ),
    );
  }

  Future<void> _contactCustomer(BuildContext context) async {
    final cleanPhone = order.consumerPhone.replaceAll(RegExp('[^0-9]'), '');
    if (cleanPhone.isEmpty) return;

    final uri = Uri.parse('https://wa.me/55$cleanPhone');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o contato do cliente.'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }
}
