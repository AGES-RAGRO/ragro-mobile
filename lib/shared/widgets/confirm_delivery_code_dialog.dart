import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

class ConfirmDeliveryCodeDialog extends StatefulWidget {
  const ConfirmDeliveryCodeDialog({
    required this.onConfirm,
    this.onCancelOrder,
    super.key,
  });

  final Future<bool> Function(String code) onConfirm;

  /// When set, shows a secondary "Cancelar pedido" action; tapping it closes
  /// the modal and invokes this callback.
  final VoidCallback? onCancelOrder;

  @override
  State<ConfirmDeliveryCodeDialog> createState() =>
      _ConfirmDeliveryCodeDialogState();
}

class _ConfirmDeliveryCodeDialogState extends State<ConfirmDeliveryCodeDialog> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  bool _hasError = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text.trim()).join();

  bool get _isFilled => _code.length == 4;

  Future<void> _confirm() async {
    if (!_isFilled || _isLoading) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final success = await widget.onConfirm(_code);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      // Clear the digits and refocus the first field.
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Confirmar Entrega',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Código do consumidor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: AppColors.placeholder,
              ),
            ),
            const SizedBox(height: 24),
            // 4-digit input row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Expanded(
                  child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: _hasError
                          ? AppColors.red
                          : AppColors.darkGreen.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: false,
                      ),
                    ),
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      cursorColor: AppColors.darkGreen,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        color: _hasError ? AppColors.red : AppColors.darkGreen,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        filled: false,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && i < 3) {
                          _focusNodes[i + 1].requestFocus();
                        }
                        if (value.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                        setState(() => _hasError = false);
                      },
                    ),
                  ),
                ));
              }),
            ),
            // Error message
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _hasError
                  ? const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Código incorreto. Tente novamente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: AppColors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.darkGreen),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Voltar',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_isFilled && !_isLoading) ? _confirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      disabledBackgroundColor:
                          AppColors.darkGreen.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Confirmar',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            if (widget.onCancelOrder != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop(false);
                        widget.onCancelOrder!();
                      },
                style: TextButton.styleFrom(foregroundColor: AppColors.red),
                child: const Text(
                  'Cancelar pedido',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
