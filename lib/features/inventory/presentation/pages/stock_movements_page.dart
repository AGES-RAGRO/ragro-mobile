import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/stock_movement.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_movements_bloc.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_movements_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_movements_state.dart';

class StockMovementsPage extends StatelessWidget {
  const StockMovementsPage({
    required this.productId,
    required this.productName,
    super.key,
  });

  final String productId;
  final String productName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<StockMovementsBloc>()..add(StockMovementsStarted(productId)),
      child: _StockMovementsView(productName: productName),
    );
  }
}

class _StockMovementsView extends StatelessWidget {
  const _StockMovementsView({required this.productName});

  final String productName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.black,
              ),
            ),
            Text(
              productName,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                color: AppColors.placeholder,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: BlocBuilder<StockMovementsBloc, StockMovementsState>(
        builder: (context, state) {
          if (state is StockMovementsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkGreen),
            );
          }
          if (state is StockMovementsFailure) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: AppColors.placeholder,
                ),
              ),
            );
          }
          if (state is StockMovementsLoaded) {
            if (state.movements.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 64, color: AppColors.placeholder),
                    SizedBox(height: 16),
                    Text(
                      'Nenhuma movimentação encontrada',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        color: AppColors.placeholder,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.movements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _MovementCard(movement: state.movements[index]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MovementCard extends StatelessWidget {
  const _MovementCard({required this.movement});

  final StockMovement movement;

  @override
  Widget build(BuildContext context) {
    final isExit = movement.type == 'EXIT';
    final color = isExit ? AppColors.red : AppColors.lightGreen;
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    final qty = movement.quantity;
    final stock = movement.currentStockQuantity;

    String fmt(double v) =>
        v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isExit
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.reasonLabel,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                if (movement.notes != null && movement.notes!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    movement.notes!,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: AppColors.placeholder,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  formatter.format(movement.createdAt.toLocal()),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    color: AppColors.placeholder,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExit ? "-" : "+"}${fmt(qty)}',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: color,
                ),
              ),
              Text(
                'Saldo: ${fmt(stock)}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  color: AppColors.placeholder,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
