import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

/// Floating footer card with the order detail action buttons.
///
/// Renders nothing when [buttons] is empty; shows a linear progress bar on
/// top of the buttons while [isBusy].
class OrderActionFooter extends StatelessWidget {
  const OrderActionFooter({
    required this.isBusy,
    required this.buttons,
    super.key,
  });

  final bool isBusy;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBusy)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: LinearProgressIndicator(color: AppColors.darkGreen),
              ),
            ...buttons
                .expand((button) => [button, const SizedBox(height: 8)])
                .take(buttons.length * 2 - 1),
          ],
        ),
      ),
    );
  }
}
