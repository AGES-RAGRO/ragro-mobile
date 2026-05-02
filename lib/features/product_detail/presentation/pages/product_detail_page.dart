// Screen: Product Detail
// User Story: US-15 — Register Product (consumer view)
// Epic: EPIC 4 — Product Management
// Routes: GET /products/:id

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:ragro_mobile/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:ragro_mobile/features/product_detail/presentation/bloc/product_detail_event.dart';
import 'package:ragro_mobile/features/product_detail/presentation/bloc/product_detail_state.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    required this.productId,
    this.producerId = '',
    super.key,
  });

  final String productId;
  final String producerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProductDetailBloc>()
            ..add(ProductDetailStarted(productId, producerId: producerId)),
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          if (state is ProductDetailLoading || state is ProductDetailInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkGreen),
            );
          }
          if (state is ProductDetailFailure) {
            return Center(child: Text(state.message));
          }
          if (state is! ProductDetailLoaded) return const SizedBox.shrink();

          final product = state.product;
          final quantity = state.quantity;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Header
                  SliverAppBar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    leading: GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.black,
                      ),
                    ),
                    title: const Text(
                      'Detalhe do Produto',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                    ),
                    pinned: true,
                    elevation: 0,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: Container(
                        color: const Color(0x1A2E5729),
                        height: 1,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Product image
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: SizedBox(
                              height: 289,
                              width: double.infinity,
                              child: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : ColoredBox(
                                      color: AppColors.mintGreen.withValues(
                                        alpha: 0.3,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.eco,
                                          size: 80,
                                          color: AppColors.darkGreen,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        // Product content card
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF6F7F6),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name + Price
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontFamily: 'Figtree',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 32,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: const TextStyle(
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Producer info
                              Text(
                                'Produtor: ${product.producerName}',
                                style: const TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 14,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.storefront_outlined,
                                    size: 14,
                                    color: AppColors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    product.farmName,
                                    style: const TextStyle(
                                      fontFamily: 'Figtree',
                                      fontSize: 14,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Category badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.category,
                                  style: const TextStyle(
                                    fontFamily: 'Figtree',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Description
                              const Text(
                                'Descrição',
                                style: TextStyle(
                                  fontFamily: 'Figtree',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.description,
                                style: const TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 14,
                                  color: AppColors.black,
                                  height: 1.6,
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
              // Sticky bottom bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 17, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    border: const Border(
                      top: BorderSide(color: Color(0x1A2E5729)),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Quantity selector
                      Container(
                        height: 53,
                        width: 113,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  context.read<ProductDetailBloc>().add(
                                    const ProductDetailQuantityDecremented(),
                                  ),
                              child: const Icon(Icons.remove, size: 16),
                            ),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontFamily: 'Figtree',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.read<ProductDetailBloc>().add(
                                    const ProductDetailQuantityIncremented(),
                                  ),
                              child: const Icon(Icons.add, size: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Add to cart button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            getIt<CartBloc>().add(
                              CartItemAdded(
                                productId: product.id,
                                quantity: quantity.toDouble(),
                              ),
                            );
                            context.push('/customer/cart');
                          },
                          child: Container(
                            height: 53,
                            decoration: BoxDecoration(
                              color: AppColors.darkGreen,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_basket_outlined,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Adicionar ao Carrinho',
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
