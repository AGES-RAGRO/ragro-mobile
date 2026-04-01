// Screen: Confirmação de Pedido - Dados Bancários
// User Story: US-10 — Checkout
// Epic: EPIC 3 — Shopping & Orders
// Routes: POST /orders (confirm)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/checkout_bloc.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/checkout_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/checkout_state.dart';
import 'package:ragro_mobile/features/orders/presentation/widgets/order_item_row.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CheckoutBloc>()..add(const CheckoutStarted('cart')),
      child: BlocListener<CheckoutBloc, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutSuccess) {
            // Clear the cart after confirming
            getIt<CartBloc>().add(const CartCleared());
            // Navigate to order detail
            context.go('/consumer/orders/${state.order.id}');
          }
        },
        child: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            if (state is CheckoutLoading || state is CheckoutInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: AppColors.darkGreen)),
              );
            }
            if (state is CheckoutFailure) {
              return Scaffold(body: Center(child: Text(state.message)));
            }
            if (state is! CheckoutReady && state is! CheckoutSuccess) return const Scaffold();

            final order = state is CheckoutReady
                ? state.order
                : (state as CheckoutSuccess).order;

            return _CheckoutView(order: order);
          },
        ),
      ),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView({required this.order});

  final Order order;

  String _formatPrice(double price) =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top app bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back, size: 16),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Confirmação de Pedido',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: ListView(
                children: [
                  // Delivery address section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Endereço de Entrega',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Alterar',
                                style: TextStyle(
                                  fontFamily: 'Figtree',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.lightGreen.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.darkGreen,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.location_on, color: AppColors.white, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.deliveryAddress.fullAddress,
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    Text(
                                      order.deliveryAddress.cityStateZip,
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 14,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Map placeholder
                        Container(
                          height: 128,
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.black),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map_outlined, color: AppColors.darkGreen, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Mapa de Entrega',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(height: 8, color: const Color(0xFFF6F7F6)),

                  // Order items summary
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Resumo dos Itens',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColors.black,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                '${order.items.length} Itens',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.darkGreen,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...order.items.map((item) => OrderItemRow(item: item)),
                      ],
                    ),
                  ),

                  // Divider
                  Container(height: 8, color: const Color(0xFFF6F7F6)),

                  // Payment & Delivery info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bank info
                        const Text(
                          'Dados Bancários do Produtor',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.placeholder),
                          ),
                          child: Column(
                            children: [
                              // Bank
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_outlined, size: 20, color: AppColors.darkGreen),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Banco', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.placeholder)),
                                        Text(order.bankInfo.bank, style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Agency + Account
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Agência', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.placeholder)),
                                        Text(order.bankInfo.agency, style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Conta Corrente', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.placeholder)),
                                        Text(order.bankInfo.account, style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Color(0xFFF1F5F9), height: 24),
                              // PIX
                              Row(
                                children: [
                                  const Icon(Icons.pix, size: 22, color: AppColors.lightGreen),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Chave PIX', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.placeholder)),
                                        Text(order.bankInfo.pixKey, style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Delivery type
                        const Text(
                          'Tipo de Entrega',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.black),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.local_shipping_outlined, size: 22),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Frete RAGRO Logística', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black)),
                                    Text('Previsão: 3 a 5 dias úteis', style: TextStyle(fontFamily: 'Manrope', fontSize: 12, color: AppColors.placeholder)),
                                  ],
                                ),
                              ),
                              Text('Grátis', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.darkGreen)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sticky footer
            Container(
              padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: const Border(top: BorderSide(color: AppColors.placeholder)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 20,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Subtotal row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontFamily: 'Manrope', fontSize: 14, color: AppColors.black)),
                      Text(_formatPrice(order.totalAmount), style: const TextStyle(fontFamily: 'Manrope', fontSize: 14, color: AppColors.black)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Frete row
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Frete', style: TextStyle(fontFamily: 'Manrope', fontSize: 14, color: AppColors.black)),
                      Text('Grátis', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.darkGreen)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Total row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total do Pedido', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.black)),
                      Text(_formatPrice(order.totalAmount), style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.black)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Confirm button
                  BlocBuilder<CheckoutBloc, CheckoutState>(
                    builder: (context, state) {
                      final isLoading = state is CheckoutLoading;
                      return GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => context.read<CheckoutBloc>().add(const CheckoutConfirmed('cart')),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator(color: AppColors.white)
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Confirmar Pedido',
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.check_circle_outline, color: AppColors.white, size: 20),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'TRANSAÇÃO SEGURA • RAGRO AGRONEGÓCIOS',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      color: AppColors.placeholder,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
