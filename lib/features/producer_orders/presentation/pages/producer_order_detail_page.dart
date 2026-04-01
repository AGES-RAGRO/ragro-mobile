// Screen: Producer Order Detail (Detalhes do Pedido - Produtor)
// User Story: US-21 — View and Manage Order Detail
// Epic: EPIC 4 — Producer Features
// Routes: GET /orders/producer/:id

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_order_detail_bloc.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_order_detail_event.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_order_detail_state.dart';

class ProducerOrderDetailPage extends StatelessWidget {
  const ProducerOrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProducerOrderDetailBloc>()
        ..add(ProducerOrderDetailStarted(orderId)),
      child: BlocConsumer<ProducerOrderDetailBloc, ProducerOrderDetailState>(
        listener: (context, state) {
          if (state is ProducerOrderDetailSuccess) {
            final msg = switch (state.action) {
              'confirmed' => 'Pedido aceito com sucesso!',
              'refused' => 'Pedido recusado.',
              'status_updated' => 'Status atualizado!',
              _ => 'Ação concluída.',
            };
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: AppColors.darkGreen,
              ),
            );
          }
          if (state is ProducerOrderDetailFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProducerOrderDetailLoading ||
              state is ProducerOrderDetailInitial) {
            return const Scaffold(
              body: Center(
                  child: CircularProgressIndicator(color: AppColors.darkGreen)),
            );
          }
          if (state is ProducerOrderDetailFailure) {
            return Scaffold(
              body: Center(child: Text(state.message)),
            );
          }

          final ProducerOrder? order = switch (state) {
            ProducerOrderDetailLoaded(:final order) => order,
            ProducerOrderDetailConfirming(:final order) => order,
            ProducerOrderDetailRefusing(:final order) => order,
            ProducerOrderDetailUpdatingStatus(:final order) => order,
            ProducerOrderDetailSuccess(:final order) => order,
            _ => null,
          };

          if (order == null) return const Scaffold();

          final isProcessing = state is ProducerOrderDetailConfirming ||
              state is ProducerOrderDetailRefusing ||
              state is ProducerOrderDetailUpdatingStatus;

          return _ProducerOrderDetailView(
            order: order,
            isProcessing: isProcessing,
          );
        },
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

  String _formatPrice(double price) =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  Color _statusColor(ProducerOrderStatus status) => switch (status) {
        ProducerOrderStatus.pending => const Color(0xFFFFC107),
        ProducerOrderStatus.accepted => AppColors.lightGreen,
        ProducerOrderStatus.inDelivery => const Color(0xFF2196F3),
        ProducerOrderStatus.delivered => AppColors.darkGreen,
        ProducerOrderStatus.cancelled => AppColors.red,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppBar area
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.arrow_back, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Detalhes do Pedido\n#${order.id}',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(order.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.status.label.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: _statusColor(order.status),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CLIENTE
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Text(
                      'CLIENTE',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.darkGreen,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.darkGreen.withOpacity(0.1),
                          child: Text(
                            order.consumerName.isNotEmpty
                                ? order.consumerName[0]
                                : '?',
                            style: const TextStyle(
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.consumerName,
                              style: const TextStyle(
                                fontFamily: 'Figtree',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColors.black,
                              ),
                            ),
                            Text(
                              'Cliente desde ${order.consumerSince}',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 13,
                                color: AppColors.placeholder,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ITENS DO PEDIDO
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'ITENS DO PEDIDO',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.darkGreen,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppColors.lightGreen.withOpacity(0.1)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ...order.items.asMap().entries.map((entry) {
                          final item = entry.value;
                          final isLast =
                              entry.key == order.items.length - 1;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: AppColors.darkGreen
                                            .withOpacity(0.05),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.eco_outlined,
                                        color: AppColors.darkGreen,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontFamily: 'Manrope',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: AppColors.black,
                                            ),
                                          ),
                                          Text(
                                            '${item.quantity} ${item.unityType}  ×  ${_formatPrice(item.unitPrice)}',
                                            style: const TextStyle(
                                              fontFamily: 'Manrope',
                                              fontSize: 13,
                                              color: AppColors.placeholder,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _formatPrice(item.totalPrice),
                                      style: const TextStyle(
                                        fontFamily: 'Figtree',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Divider(
                                  color:
                                      AppColors.lightGreen.withOpacity(0.1),
                                  height: 1,
                                ),
                            ],
                          );
                        }),
                        // Total row
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen.withOpacity(0.06),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: AppColors.lightGreen.withOpacity(0.15),
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: AppColors.black,
                                ),
                              ),
                              Text(
                                _formatPrice(order.totalPrice),
                                style: const TextStyle(
                                  fontFamily: 'Figtree',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ENTREGA
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'ENTREGA',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.darkGreen,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.lightGreen.withOpacity(0.1)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 20, color: AppColors.darkGreen),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order.deliveryAddress}, ${order.deliveryNeighborhood}',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.black,
                                ),
                              ),
                              Text(
                                order.deliveryCityState,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  color: AppColors.placeholder,
                                ),
                              ),
                              if (order.deliveryComplement.isNotEmpty)
                                Text(
                                  order.deliveryComplement,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 13,
                                    color: AppColors.placeholder,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sticky bottom actions
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomActions(order: order, isProcessing: isProcessing),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.order, required this.isProcessing});

  final ProducerOrder order;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProducerOrderDetailBloc>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (order.status == ProducerOrderStatus.pending) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () => bloc.add(ProducerOrderDetailRefused(order.id)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor:
                          AppColors.red.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Recusar pedido',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () =>
                            bloc.add(ProducerOrderDetailConfirmed(order.id)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor:
                          AppColors.darkGreen.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            'Confirmar Pedido',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ] else if (order.status == ProducerOrderStatus.accepted) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isProcessing
                    ? null
                    : () => bloc.add(ProducerOrderDetailStatusUpdated(
                          order.id,
                          ProducerOrderStatus.inDelivery,
                        )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'Marcar como A caminho',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ] else if (order.status == ProducerOrderStatus.inDelivery) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isProcessing
                    ? null
                    : () => bloc.add(ProducerOrderDetailStatusUpdated(
                          order.id,
                          ProducerOrderStatus.delivered,
                        )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'Confirmar Entrega',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ] else if (order.status == ProducerOrderStatus.delivered) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen.withOpacity(0.4),
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Pedido entregue',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],

          // Contact button (not shown for cancelled/delivered)
          if (order.status != ProducerOrderStatus.delivered &&
              order.status != ProducerOrderStatus.cancelled) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Abrindo WhatsApp...'),
                      backgroundColor: Color(0xFF25D366),
                    ),
                  );
                },
                icon: const Icon(Icons.chat, size: 18),
                label: const Text(
                  'Contatar Cliente',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
