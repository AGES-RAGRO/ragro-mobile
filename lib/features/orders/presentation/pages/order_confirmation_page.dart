// Screen: Confirmação de Pedido - Dados Bancários
// User Story: US-10 — Checkout
// Epic: EPIC 3 — Shopping & Orders
// Routes: POST /orders (confirm)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/checkout_bloc.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/checkout_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/checkout_state.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CheckoutBloc>()..add(const CheckoutStarted('cart')),
      child: BlocListener<CheckoutBloc, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutSuccess) {
            getIt<CartBloc>().add(const CartOrderPlaced());
            context.go('/customer/orders/${state.order.id}');
          }
          if (state is CheckoutFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_friendlyError(state.message)),
                backgroundColor: AppColors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            if (state is CheckoutLoading || state is CheckoutInitial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.darkGreen),
                ),
              );
            }

            final cart = switch (state) {
              CheckoutReady(:final cart) => cart,
              CheckoutConfirming(:final cart) => cart,
              CheckoutFailure(:final cart) => cart,
              _ => null,
            };

            if (cart == null) {
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
                            Icons.shopping_cart_outlined,
                            size: 56,
                            color: AppColors.placeholder,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Não foi possível carregar o carrinho.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<CheckoutBloc>()
                                .add(const CheckoutStarted('cart')),
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

            return _CheckoutView(
              cart: cart,
              isConfirming: state is CheckoutConfirming,
            );
          },
        ),
      ),
    );
  }

  static String _friendlyError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('400') || lower.contains('invalid')) {
      return 'Pedido inválido. Verifique seu carrinho e tente novamente.';
    }
    if (lower.contains('401') || lower.contains('unauthorized')) {
      return 'Sessão expirada. Faça login novamente.';
    }
    if (lower.contains('404') || lower.contains('notfound')) {
      return 'Carrinho não encontrado.';
    }
    return 'Não foi possível confirmar o pedido. Tente novamente.';
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView({required this.cart, this.isConfirming = false});

  final Cart cart;
  final bool isConfirming;

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
                            color: AppColors.lightGreen.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.lightGreen.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.darkGreen,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cart.farmName,
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    Text(
                                      'Endereço será confirmado pelo cadastro',
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
                            color: AppColors.lightGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.black),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  color: AppColors.darkGreen,
                                  size: 24,
                                ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                '${cart.items.length} Itens',
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
                        ...cart.items.map((item) => _CartItemRow(item: item)),
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
                                  const Icon(
                                    Icons.account_balance_outlined,
                                    size: 20,
                                    color: AppColors.darkGreen,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Banco',
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.placeholder,
                                          ),
                                        ),
                                        Text(
                                          cart.bankName.isNotEmpty
                                              ? cart.bankName
                                              : '-',
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.black,
                                          ),
                                        ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Agência',
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: AppColors.placeholder,
                                          ),
                                        ),
                                        Text(
                                          cart.bankAgency.isNotEmpty
                                              ? cart.bankAgency
                                              : '-',
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Conta Corrente',
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: AppColors.placeholder,
                                          ),
                                        ),
                                        Text(
                                          cart.bankAccount.isNotEmpty
                                              ? cart.bankAccount
                                              : '-',
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Color(0xFFF1F5F9),
                                height: 24,
                              ),
                              // PIX
                              Row(
                                children: [
                                  const Icon(
                                    Icons.pix,
                                    size: 22,
                                    color: AppColors.lightGreen,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Chave PIX',
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: AppColors.placeholder,
                                          ),
                                        ),
                                        Text(
                                          cart.bankPixKey.isNotEmpty
                                              ? cart.bankPixKey
                                              : 'Disponível nos detalhes do pedido',
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.black,
                                          ),
                                        ),
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
                                    Text(
                                      'Frete RAGRO Logística',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    Text(
                                      'Previsão: 3 a 5 dias úteis',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 12,
                                        color: AppColors.placeholder,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Grátis',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.darkGreen,
                                ),
                              ),
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
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.placeholder)),
                boxShadow: [
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
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        _formatPrice(cart.totalAmount),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Frete row
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Frete',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        'Grátis',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Total row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total do Pedido',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        _formatPrice(cart.totalAmount),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Confirm button
                  GestureDetector(
                    onTap: isConfirming
                        ? null
                        : () => context.read<CheckoutBloc>().add(
                            const CheckoutConfirmed('cart'),
                          ),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isConfirming
                            ? AppColors.darkGreen.withValues(alpha: 0.7)
                            : AppColors.darkGreen,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: isConfirming
                            ? const CircularProgressIndicator(
                                color: AppColors.white,
                              )
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
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),
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

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item});

  final CartItem item;

  String _formatPrice(double price) =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  String _formatQuantity(double quantity) {
    if (quantity % 1 == 0) return quantity.toInt().toString();
    return quantity.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          const SizedBox(width: 16),
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
                  'Qtd: ${_formatQuantity(item.quantity)}${item.unityType}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: AppColors.placeholder,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatPrice(item.subtotal),
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
