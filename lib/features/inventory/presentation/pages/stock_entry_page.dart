import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_entry_bloc.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_entry_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_entry_state.dart';
import 'package:ragro_mobile/features/inventory/presentation/widgets/stock_movement_form.dart';

class StockEntryPage extends StatelessWidget {
  const StockEntryPage({
    required this.productId,
    required this.productName,
    required this.unit,
    super.key,
  });

  final String productId;
  final String productName;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StockEntryBloc>(),
      child: BlocConsumer<StockEntryBloc, StockEntryState>(
        listener: (context, state) {
          if (state is StockEntrySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Entrada registrada com sucesso!'),
                backgroundColor: AppColors.darkGreen,
              ),
            );
            context.pop(true);
          } else if (state is StockEntryFailure) {
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
            title: 'Registrar Entrada',
            productName: productName,
            unit: unit,
            accentColor: AppColors.lightGreen,
            notesHint: 'Ex: reposição de estoque...',
            submitLabel: 'Confirmar Entrada',
            submitColor: AppColors.lightGreen,
            isLoading: state is StockEntryLoading,
            onSubmit: (quantity, _, notes) {
              context.read<StockEntryBloc>().add(
                StockEntrySubmitted(
                  productId: productId,
                  quantity: quantity,
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
