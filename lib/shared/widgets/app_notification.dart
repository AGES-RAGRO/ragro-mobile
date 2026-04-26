import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

class AppNotification {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, isError: false);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, isError: true);
  }

  static void _show(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (context) => _NotificationWidget(
            message: message,
            isError: isError,
            onDismiss: () {
              entry.remove();
            },
          ),
    );

    overlay.insert(entry);
  }
}

class _NotificationWidget extends StatefulWidget {
  const _NotificationWidget({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    _timer = Timer(const Duration(seconds: 4), () {
      _hide();
    });
  }

  void _hide() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;

    return Positioned(
      top: safeAreaTop + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < -10) {
                _hide();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isError ? AppColors.red : AppColors.darkGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.isError ? 'Ops!' : 'Sucesso',
                          style: const TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
