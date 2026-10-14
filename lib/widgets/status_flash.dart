import 'package:flutter/material.dart';

enum StatusFlashKind { success, error }

class StatusFlash {
  StatusFlash._();

  static OverlayEntry? _current;

  static void success(BuildContext context, [String? message]) {
    _show(context, StatusFlashKind.success, message);
  }

  static void fail(BuildContext context, [String? message]) {
    _show(context, StatusFlashKind.error, message);
  }

  static void _show(
      BuildContext context, StatusFlashKind kind, String? message) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _current?.remove();
    _current = null;

    final isSuccess = kind == StatusFlashKind.success;
    final color =
    isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFFF5252);
    final icon = isSuccess ? Icons.check_rounded : Icons.close_rounded;

    final entry = OverlayEntry(
      builder: (_) => _StatusFlashOverlay(
        icon: icon,
        color: color,
        message: message,
        onDone: () {
          _current?.remove();
          _current = null;
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

class _StatusFlashOverlay extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String? message;
  final VoidCallback onDone;

  const _StatusFlashOverlay({
    required this.icon,
    required this.color,
    required this.message,
    required this.onDone,
  });

  @override
  State<_StatusFlashOverlay> createState() => _StatusFlashOverlayState();
}

class _StatusFlashOverlayState extends State<_StatusFlashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _ctrl.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 100,
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final t = _ctrl.value;

              double opacity;
              if (t < 0.15) {
                opacity = t / 0.15;
              } else if (t < 0.72) {
                opacity = 1.0;
              } else {
                opacity = (1.0 - (t - 0.72) / 0.28).clamp(0.0, 1.0);
              }

              double scale;
              if (t < 0.15) {
                scale = t / 0.15;
              } else if (t < 0.72) {
                scale = 1.0;
              } else {
                scale = (1.0 - (t - 0.72) / 0.28).clamp(0.0, 1.0);
              }

              double angle;
              if (t < 0.10) {
                angle = -3.7699;
              } else if (t < 0.45) {
                final p = (t - 0.10) / 0.35;
                angle = -3.7699 + p * (3.7699 - 0.7854);
              } else if (t < 0.60) {
                final p = (t - 0.45) / 0.15;
                angle = -0.7854 * (1 - p);
              } else {
                angle = 0;
              }

              return Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: angle,
                  child: Transform.scale(
                    scale: scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.color.withValues(alpha: 0.18),
                            border:
                            Border.all(color: widget.color, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withValues(alpha: 0.5),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(widget.icon,
                              color: widget.color, size: 48),
                        ),
                        if (widget.message != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.message!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}