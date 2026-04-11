// Screen: Inventory (Estoque do Produtor)
// User Story: US-22 — Manage Product Inventory
// Epic: EPIC 4 — Producer Features
// Routes: GET /products

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:ragro_mobile/features/inventory/presentation/widgets/inventory_product_card.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InventoryBloc>()..add(const InventoryStarted()),
      child: const _InventoryView(),
    );
  }
}

class _InventoryView extends StatelessWidget {
  const _InventoryView();

  static const _filters = [
    ('all', 'Todos'),
    ('active', 'Ativos'),
    ('unavailable', 'Indisponíveis'),
  ];

  String _formatPrice(double price) =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estoque',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w700,
                          fontSize: 34,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      if (state is InventoryLoaded)
                        GestureDetector(
                          onTap: () => context.push('/producer/stock/new'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkGreen,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 16,
                                  color: AppColors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Novo',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Summary cards
                if (state is InventoryLoaded) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Itens',
                            value: '${state.totalItems}',
                            icon: Icons.inventory_2_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Valor Total',
                            value: _formatPrice(state.totalValue),
                            icon: Icons.attach_money,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Meus Produtos label
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      'Meus Produtos',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                    ),
                  ),

                  // Filter pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: _filters.map((f) {
                        final isActive = state.activeFilter == f.$1;
                        final count = f.$1 == 'all'
                            ? state.totalItems
                            : f.$1 == 'active'
                            ? state.products
                                  .where((p) => p.active && p.stock > 0)
                                  .length
                            : null;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => context.read<InventoryBloc>().add(
                              InventoryFilterChanged(f.$1),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.darkGreen
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.darkGreen
                                      : AppColors.placeholder,
                                ),
                              ),
                              child: Text(
                                count != null ? '${f.$2}($count)' : f.$2,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isActive
                                      ? AppColors.white
                                      : AppColors.placeholder,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Product list
                  Expanded(
                    child: state.products.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: AppColors.placeholder,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Nenhum produto encontrado',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 16,
                                    color: AppColors.placeholder,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: state.products.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final product = state.products[index];
                              return InventoryProductCard(
                                product: product,
                                onEditTap: () => context.push(
                                  '/producer/stock/${product.id}/edit',
                                ),
                                onDeleteTap: () => _confirmDelete(
                                  context,
                                  product.id,
                                  product.name,
                                ),
                              );
                            },
                          ),
                  ),
                ] else if (state is InventoryLoading) ...[
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                ] else if (state is InventoryFailure) ...[
                  Expanded(child: Center(child: Text(state.message))),
                ] else ...[
                  const Expanded(child: SizedBox.shrink()),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String productId,
    String productName,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Excluir produto?',
          style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Tem certeza que deseja excluir "$productName"?',
          style: const TextStyle(fontFamily: 'Manrope'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.placeholder),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<InventoryBloc>().add(
                InventoryProductDeleted(productId),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Excluir',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.darkGreen),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: AppColors.placeholder,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
