// Screen: Producer Order Detail (Detalhes do Pedido - Produtor)
// User Story: US-21 - View and Manage Order Detail
// Epic: EPIC 4 - Producer Features
// Routes: GET /orders/producer/:id

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_item.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_order_detail_bloc.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_order_detail_event.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_order_detail_state.dart';
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
      create: (_) =>
          getIt<ProducerOrderDetailBloc>()
            ..add(
              ProducerOrderDetailStarted(orderId, initialOrder: initialOrder),
            ),
      child: BlocConsumer<ProducerOrderDetailBloc, ProducerOrderDetailState>(
        listener: (context, state) {
          if (state is ProducerOrderDetailSuccess) {
            if (state.action == 'status_updated') {
              if (state.order.status == ProducerOrderStatus.delivered) {
                context.pop('delivered');
              } else {
                context.pop('in_delivery');
              }
              return;
            }
            if (state.action == 'refused') {
              context.pop('cancelled');
              return;
            }
            final message = switch (state.action) {
              'confirmed' => 'Pedido aceito com sucesso.',
              _ => 'Ação concluída.',
            };
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.darkGreen,
              ),
            );
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
            _ => null,
          };
          if (order == null) return const Scaffold();

          final isProcessing =
              state is ProducerOrderDetailConfirming ||
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

  @override
  Widget build(BuildContext context) {
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
                  const _SectionTitle('ITENS DO PEDIDO'),
                  _ItemsCard(order: order),
                  const SizedBox(height: 18),
                  const _SectionTitle('ENTREGA'),
                  _DeliveryCard(order: order),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _ActionFooter(order: order, isProcessing: isProcessing),
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
    final shortId = order.id.length > 4 ? order.id.substring(0, 4) : order.id;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
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
                  '#$shortId',
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
          _StatusBadge(status: order.status),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.darkGreen,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ProducerOrderStatus status;

  Color get _color => switch (status) {
    ProducerOrderStatus.pending => const Color(0xFFFFB413),
    ProducerOrderStatus.accepted => AppColors.lightGreen,
    ProducerOrderStatus.inDelivery => AppColors.lightGreen,
    ProducerOrderStatus.delivered => const Color(0xFF3B82F6),
    ProducerOrderStatus.cancelled => AppColors.red,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: 10,
          color: AppColors.white,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final ProducerOrder order;

  static final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          ...order.items.asMap().entries.map((entry) {
            final isLast = entry.key == order.items.length - 1;
            return Column(
              children: [
                _ProducerOrderItemRow(item: entry.value),
                if (!isLast)
                  Divider(
                    color: AppColors.lightGreen.withValues(alpha: 0.08),
                    height: 1,
                  ),
              ],
            );
          }),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  _currency.format(order.totalPrice),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.darkGreen,
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

class _ProducerOrderItemRow extends StatelessWidget {
  const _ProducerOrderItemRow({required this.item});

  final ProducerOrderItem item;

  static final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
  );

  String get _quantity => 'Qtd: ${item.quantity}${item.unityType}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.lightGreen.withValues(alpha: 0.05),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(item.imageUrl, fit: BoxFit.cover)
                  : const Icon(Icons.eco, color: AppColors.lightGreen),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _quantity,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: AppColors.placeholder,
                  ),
                ),
                Text(
                  _currency.format(item.unitPrice),
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
            _currency.format(item.totalPrice),
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.order});

  final ProducerOrder order;

  @override
  Widget build(BuildContext context) {
    final lines = [
      order.deliveryAddress,
      [
        order.deliveryNeighborhood,
        order.deliveryCityState,
      ].where((line) => line.isNotEmpty).join(', '),
      order.deliveryComplement,
    ].where((line) => line.isNotEmpty).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 20,
            color: AppColors.darkGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Endereço',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 6),
                ...lines.map(
                  (line) => Text(
                    line,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      color: AppColors.black,
                    ),
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
  const _ActionFooter({required this.order, required this.isProcessing});

  final ProducerOrder order;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      if (order.status == ProducerOrderStatus.pending)
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Recusar Pedido',
                icon: Icons.cancel_outlined,
                color: AppColors.red,
                onTap: isProcessing ? null : () => _confirmCancel(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                label: 'Confirmar Pedido',
                icon: Icons.check_circle_outline,
                color: AppColors.darkGreen,
                onTap: isProcessing
                    ? null
                    : () => context.read<ProducerOrderDetailBloc>().add(
                        ProducerOrderDetailConfirmed(order.id),
                      ),
              ),
            ),
          ],
        ),
      if (order.status == ProducerOrderStatus.accepted)
        _ActionButton(
          label: 'Iniciar Entrega',
          icon: Icons.local_shipping_outlined,
          color: AppColors.darkGreen,
          onTap: isProcessing
              ? null
              : () => context.read<ProducerOrderDetailBloc>().add(
                  ProducerOrderDetailStatusUpdated(
                    order.id,
                    ProducerOrderStatus.inDelivery,
                  ),
                ),
        ),
      if (order.status == ProducerOrderStatus.inDelivery)
        _ActionButton(
          label: 'Confirmar Entrega',
          icon: Icons.check_circle_outline,
          color: AppColors.darkGreen,
          onTap: isProcessing
              ? null
              : () => _confirmDelivery(context),
        ),
      if (order.consumerPhone.isNotEmpty &&
          order.status != ProducerOrderStatus.cancelled)
        _ActionButton(
          label: 'Contatar Cliente',
          icon: Icons.chat,
          color: const Color(0xFF25D366),
          onTap: isProcessing ? null : () => _contactCustomer(context),
        ),
    ];

    if (buttons.isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isProcessing)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: LinearProgressIndicator(color: AppColors.darkGreen),
              ),
            ...buttons
                .expand((button) => [button, const SizedBox(height: 8)])
                .take(buttons.length * 2 - 1),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar pedido'),
        content: const Text('Tem certeza que deseja cancelar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancelar pedido'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      context.read<ProducerOrderDetailBloc>().add(
        ProducerOrderDetailRefused(order.id),
      );
    }
  }

  Future<void> _confirmDelivery(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar entrega'),
        content: const Text(
          'Tem certeza que deseja confirmar a entrega deste pedido?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmar entrega'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      context.read<ProducerOrderDetailBloc>().add(
        ProducerOrderDetailStatusUpdated(
          order.id,
          ProducerOrderStatus.delivered,
        ),
      );
    }
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: onTap == null ? color.withValues(alpha: 0.6) : color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
