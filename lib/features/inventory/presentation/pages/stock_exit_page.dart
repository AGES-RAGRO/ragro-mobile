import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_exit_bloc.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_exit_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_exit_state.dart';
import 'package:ragro_mobile/features/inventory/presentation/widgets/stock_movement_form.dart';
import 'package:ragro_mobile/shared/utils/unity_type_label.dart';

class StockExitPage extends StatelessWidget {
  const StockExitPage({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.currentStock,
    super.key,
  });

  final String productId;
  final String productName;
  final String unit;
  final double currentStock;

  static const _reasons = [('LOSS', 'Perda'), ('DISPOSAL', 'Descarte')];

  String get _currentStockLabel =>
      'Saldo atual: ${currentStock % 1 == 0 ? currentStock.toInt() : currentStock.toStringAsFixed(2)} ${localizeUnityType(unit)}';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StockExitBloc>(),
      child: BlocConsumer<StockExitBloc, StockExitState>(
        listener: (context, state) {
          if (state is StockExitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saída registrada com sucesso!'),
                backgroundColor: AppColors.darkGreen,
              ),
            );
            context.pop(true);
          } else if (state is StockExitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return StockMovementForm(
            title: 'Registrar Saída',
            productName: productName,
            unit: unit,
            accentColor: AppColors.darkGreen,
            productSubtitle: _currentStockLabel,
            notesHint: 'Descreva o motivo da saída...',
            submitLabel: 'Confirmar Saída',
            submitColor: AppColors.red,
            isLoading: state is StockExitLoading,
            maxQuantity: currentStock,
            maxQuantityMessage: 'Quantidade superior ao saldo em estoque.',
            reasons: _reasons,
            onSubmit: (quantity, reason, notes) {
              context.read<StockExitBloc>().add(
                StockExitSubmitted(
                  productId: productId,
                  quantity: quantity,
                  reason: reason ?? _reasons.first.$1,
                  notes: notes,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
