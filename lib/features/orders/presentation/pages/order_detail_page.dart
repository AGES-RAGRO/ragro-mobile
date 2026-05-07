// Screen: Detalhes do Pedido
// User Story: US-12 - View Order Details
// Epic: EPIC 3 - Shopping & Orders
// Routes: GET /orders/customer/:id

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/order_detail_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/order_detail_state.dart';
import 'package:ragro_mobile/shared/widgets/cancel_order_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderDetailBloc>()..add(OrderDetailStarted(orderId)),
      child: BlocConsumer<OrderDetailBloc, OrderDetailState>(
        listener: (context, state) {
          if (state is OrderDetailActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.darkGreen,
              ),
            );
          }
          if (state is OrderDetailActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            OrderDetailLoading() || OrderDetailInitial() => const Scaffold(
              backgroundColor: AppColors.white,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.darkGreen),
              ),
            ),
            OrderDetailFailure(:final message) => _OrderDetailErrorView(
              orderId: orderId,
              message: _friendlyErrorMessage(message),
            ),
            OrderDetailLoaded(:final order) => _OrderDetailView(order: order),
            OrderDetailUpdating(:final order) => _OrderDetailView(
              order: order,
              isUpdating: true,
            ),
            OrderDetailActionSuccess(:final order) => _OrderDetailView(
              order: order,
            ),
            OrderDetailActionFailure(:final order) => _OrderDetailView(
              order: order,
            ),
          };
        },
      ),
    );
  }

  static String _friendlyErrorMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('404') ||
        lower.contains('notfound') ||
        lower.contains('não encontrado') ||
        lower.contains('nao encontrado')) {
      return 'Pedido não encontrado.';
    }
    return 'Não foi possível carregar os detalhes do pedido.';
  }
}

class _OrderDetailErrorView extends StatelessWidget {
  const _OrderDetailErrorView({required this.orderId, required this.message});

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
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<OrderDetailBloc>().add(
                    OrderDetailStarted(orderId),
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

class _OrderDetailView extends StatelessWidget {
  const _OrderDetailView({required this.order, this.isUpdating = false});

  final OrderDetail order;
  final bool isUpdating;

  static final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
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
                                order.displayNumber,
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
                        _StatusBadge(order: order),
                      ],
                    ),
                  ),
                  if (order.producerName.isNotEmpty) _ProducerHeader(order),
                  const _SectionTitle('ITENS DO PEDIDO'),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.lightGreen.withValues(alpha: 0.08),
                      ),
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
                              _OrderDetailItemRow(item: entry.value),
                              if (!isLast)
                                Divider(
                                  color: AppColors.lightGreen.withValues(
                                    alpha: 0.08,
                                  ),
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
                                _currency.format(order.totalAmount),
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
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('ENTREGA'),
                  _DeliveryCard(address: order.deliveryAddress),
                  if (order.bankInfo != null && order.bankInfo!.hasAnyInfo) ...[
                    const SizedBox(height: 18),
                    const _SectionTitle('PAGAMENTO'),
                    _PaymentCard(bankInfo: order.bankInfo!),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _ActionFooter(order: order, isUpdating: isUpdating),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProducerHeader extends StatelessWidget {
  const _ProducerHeader(this.order);

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Row(
        children: [
          _ProducerAvatar(url: order.producerPicture),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.producerName,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
                if (order.createdAt != null)
                  Text(
                    DateFormat(
                      'dd/MM/yyyy, HH:mm',
                      'pt_BR',
                    ).format(order.createdAt!),
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

class _ProducerAvatar extends StatelessWidget {
  const _ProducerAvatar({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightGreen.withValues(alpha: 0.12),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasUrl
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.storefront, color: AppColors.lightGreen),
              ),
            )
          : const Center(
              child: Icon(Icons.storefront, color: AppColors.lightGreen),
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
  const _StatusBadge({required this.order});

  final OrderDetail order;

  Color get _color {
    return switch (order.status) {
      'PENDING' => const Color(0xFFFFB413),
      'CONFIRMED' => AppColors.lightGreen,
      'IN_DELIVERY' => AppColors.lightGreen,
      'DELIVERED' => const Color(0xFF3B82F6),
      'CANCELLED' => AppColors.red,
      _ => AppColors.placeholder,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        order.friendlyStatusLabel.toUpperCase(),
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

class _OrderDetailItemRow extends StatelessWidget {
  const _OrderDetailItemRow({required this.item});

  final OrderDetailItem item;

  static final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
  );

  String get _quantity {
    final value = item.quantity % 1 == 0
        ? item.quantity.toInt().toString()
        : item.quantity.toStringAsFixed(2).replaceAll('.', ',');
    return 'Qtd: $value${item.unityType}';
  }

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
              child: item.productPhoto.isNotEmpty
                  ? Image.network(
                      item.productPhoto,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.eco, color: AppColors.lightGreen),
                    )
                  : const Icon(Icons.eco, color: AppColors.lightGreen),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
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
            _currency.format(item.subtotal),
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
  const _DeliveryCard({required this.address});

  final OrderDetailAddress address;

  @override
  Widget build(BuildContext context) {
    final lines = [
      address.streetLine,
      address.cityLine,
      if (address.zipCode.isNotEmpty) 'CEP: ${address.zipCode}',
      address.reference,
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

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.bankInfo});

  final OrderDetailBankInfo bankInfo;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
                color: AppColors.darkGreen,
              ),
              SizedBox(width: 12),
              Text(
                'Dados para pagamento',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          if (bankInfo.pixKey.isNotEmpty) ...[
            const SizedBox(height: 14),
            _PixRow(pixKey: bankInfo.pixKey),
          ],
          if (bankInfo.bank.isNotEmpty || bankInfo.account.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            if (bankInfo.bank.isNotEmpty)
              _InfoRow(label: 'Banco', value: bankInfo.bank),
            if (bankInfo.agency.isNotEmpty) ...[
              const SizedBox(height: 6),
              _InfoRow(label: 'Agência', value: bankInfo.agency),
            ],
            if (bankInfo.account.isNotEmpty) ...[
              const SizedBox(height: 6),
              _InfoRow(label: 'Conta', value: bankInfo.account),
            ],
          ],
        ],
      ),
    );
  }
}

class _PixRow extends StatelessWidget {
  const _PixRow({required this.pixKey});

  final String pixKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            'PIX',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pixKey,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: AppColors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: pixKey));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chave PIX copiada!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.darkGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'COPIAR',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: AppColors.placeholder,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionFooter extends StatelessWidget {
  const _ActionFooter({required this.order, required this.isUpdating});

  final OrderDetail order;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      if (order.canConfirmDelivery)
        _ActionButton(
          label: 'Confirmar Entrega',
          icon: Icons.check_circle_outline,
          color: AppColors.darkGreen,
          onTap: isUpdating
              ? null
              : () => context.read<OrderDetailBloc>().add(
                  OrderDetailDeliveryConfirmed(order.id),
                ),
        ),
      if (order.canCancel)
        _ActionButton(
          label: 'Cancelar Pedido',
          icon: Icons.cancel_outlined,
          color: AppColors.red,
          onTap: isUpdating ? null : () => _confirmCancel(context),
        ),
      if (order.canContactProducer)
        _ActionButton(
          label: 'Contatar Produtor',
          icon: Icons.chat,
          color: const Color(0xFF25D366),
          onTap: isUpdating ? null : () => _contactProducer(context),
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
            if (isUpdating)
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
    final result = await CancelOrderDialog.showForCustomer(context);
    if (result != null && context.mounted) {
      context.read<OrderDetailBloc>().add(
        OrderDetailCancelled(order.id, reason: result.reason, details: result.details),
      );
    }
  }

  Future<void> _contactProducer(BuildContext context) async {
    final cleanPhone = (order.producerPhone ?? '').replaceAll(
      RegExp('[^0-9]'),
      '',
    );
    if (cleanPhone.isEmpty) return;

    final uri = Uri.parse('https://wa.me/55$cleanPhone');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o contato do produtor.'),
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
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
