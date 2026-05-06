import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_exit_bloc.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_exit_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_exit_state.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StockExitBloc>(),
      child: _StockExitView(
        productId: productId,
        productName: productName,
        unit: unit,
        currentStock: currentStock,
      ),
    );
  }
}

class _StockExitView extends StatefulWidget {
  const _StockExitView({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.currentStock,
  });

  final String productId;
  final String productName;
  final String unit;
  final double currentStock;

  @override
  State<_StockExitView> createState() => _StockExitViewState();
}

class _StockExitViewState extends State<_StockExitView> {
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedReason = 'LOSS';

  static const _reasons = [
    ('LOSS', 'Perda'),
    ('DISPOSAL', 'Descarte'),
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final qtyText = _quantityController.text.trim().replaceAll(',', '.');
    final qty = double.tryParse(qtyText);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe uma quantidade válida.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    if (qty > widget.currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantidade superior ao saldo em estoque.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    context.read<StockExitBloc>().add(
      StockExitSubmitted(
        productId: widget.productId,
        quantity: qty,
        reason: _selectedReason,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockExitBloc, StockExitState>(
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
      child: BlocBuilder<StockExitBloc, StockExitState>(
        builder: (context, state) {
          final isLoading = state is StockExitLoading;
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.black),
                onPressed: () => context.pop(),
              ),
              title: const Text(
                'Registrar Saída',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.black,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.eco_outlined,
                            color: AppColors.darkGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.productName,
                                style: const TextStyle(
                                  fontFamily: 'Figtree',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              Text(
                                'Saldo atual: ${widget.currentStock % 1 == 0 ? widget.currentStock.toInt() : widget.currentStock.toStringAsFixed(2)} ${widget.unit}',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 13,
                                  color:
                                      AppColors.darkGreen.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const _FieldLabel('Quantidade'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9,.]')),
                    ],
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixText: widget.unit,
                      hintStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        color: AppColors.placeholder,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.darkGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const _FieldLabel('Motivo'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedReason,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: _reasons
                          .map(
                            (r) => DropdownMenuItem(
                              value: r.$1,
                              child: Text(
                                r.$2,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 15,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (val) {
                              if (val != null) {
                                setState(() => _selectedReason = val);
                              }
                            },
                    ),
                  ),

                  const SizedBox(height: 16),

                  const _FieldLabel('Observações (opcional)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    maxLength: 500,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Descreva o motivo da saída...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        color: AppColors.placeholder,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.darkGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.red.withValues(
                          alpha: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text(
                              'Confirmar Saída',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.black,
      ),
    );
  }
}
