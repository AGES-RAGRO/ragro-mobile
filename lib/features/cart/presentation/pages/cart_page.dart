// Screen: Carrinho de Compras
// User Story: US-09 — Manage Cart
// Epic: EPIC 3 — Shopping & Orders
// Routes: GET /customers/carts, DELETE /customers/carts,
//         POST /customers/carts/items,
//         PATCH /customers/carts/items/{cartItemId},
//         DELETE /customers/carts/items/{cartItemId}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_state.dart';
import 'package:ragro_mobile/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:ragro_mobile/features/cart/presentation/widgets/producer_cart_header.dart';
import 'package:ragro_mobile/shared/widgets/app_notification.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  String _formatPrice(double price) =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  Cart? _cartFromState(CartState state) => switch (state) {
    CartLoaded(:final cart) => cart,
    CartUpdating(:final cart) => cart,
    CartUpdateFailure(:final cart) => cart,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<CartBloc>()..add(const CartStarted()),
      child: BlocConsumer<CartBloc, CartState>(
        listenWhen: (_, current) => current is CartUpdateFailure,
        listener: (context, state) {
          if (state is CartUpdateFailure) {
            AppNotification.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is CartLoading || state is CartInitial) {
            return const Scaffold(
              backgroundColor: AppColors.white,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.darkGreen),
              ),
            );
          }

          if (state is CartFailure) {
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
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              context.read<CartBloc>().add(const CartStarted()),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final cart = _cartFromState(state);
          final isEmpty = cart == null || cart.isEmpty;
          final isMutating = state is CartUpdating;

          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 20, 17),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF1F5F9)),
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.arrow_back, size: 16),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Meu Carrinho',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.black,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: isEmpty || isMutating
                              ? null
                              : () => context.read<CartBloc>().add(
                                  const CartCleared(),
                                ),
                          child: Text(
                            'Limpar',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isEmpty
                                  ? Colors.transparent
                                  : AppColors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isEmpty)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: AppColors.placeholder,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Seu carrinho está vazio',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                color: AppColors.placeholder,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Stack(
                        children: [
                          ListView(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            children: [
                              // Info banner
                              Container(
                                margin: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                padding: const EdgeInsets.all(17),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF487ACB,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF487ACB),
                                  ),
                                ),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Color(0xFF487ACB),
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Aviso de Produtor Único',
                                            style: TextStyle(
                                              fontFamily: 'Figtree',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Color(0xFF487ACB),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Para garantir o frescor e logística, você só pode comprar de um produtor por vez.',
                                            style: TextStyle(
                                              fontFamily: 'Manrope',
                                              fontSize: 12,
                                              color: Color(0xFF487ACB),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Producer header
                              ProducerCartHeader(
                                farmName: cart.farmName,
                                producerId: cart.producerId,
                              ),
                              const SizedBox(height: 16),

                              // Items
                              ...cart.items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: CartItemTile(
                                    item: item,
                                    producerId: cart.producerId,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isMutating)
                            const Positioned.fill(
                              child: ColoredBox(
                                color: Color(0x33FFFFFF),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Bottom section
                  if (!isEmpty)
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 9, 24, 24),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFF1F5F9)),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppColors.black,
                                ),
                              ),
                              Text(
                                _formatPrice(cart.totalAmount),
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: isMutating
                                ? null
                                : () => context.push('/customer/checkout'),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.darkGreen,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Text(
                                  'Finalizar Pedido',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
