import 'package:flutter/material.dart';

enum StatusFlashKind { success, error }

class StatusFlash {
  StatusFlash._();

  static OverlayEntry? _current;

  /// Shows a floating Success (✓) icon.
  /// Use [isGameBoard] = true to keep the game-specific positioning (bottom-left).
  static void success(BuildContext context, [String? message, bool isGameBoard = false]) {
    _show(context, StatusFlashKind.success, isGameBoard);
  }

  /// Shows a floating Error (✗) icon.
  /// Use [isGameBoard] = true to keep the game-specific positioning (bottom-left).
  static void fail(BuildContext context, [String? message, bool isGameBoard = false]) {
    _show(context, StatusFlashKind.error, isGameBoard);
  }

  static void _show(BuildContext context, StatusFlashKind kind, bool isGameBoard) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _current?.remove();
    _current = null;

    final isSuccess = kind == StatusFlashKind.success;
    final color = isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFFF5252);
    final icon = isSuccess ? Icons.check_rounded : Icons.close_rounded;

    final entry = OverlayEntry(
      builder: (_) => _StatusFlashOverlay(
        icon: icon,
        color: color,
        isGameBoard: isGameBoard, // <── Pass the flag to the widget
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
  final bool isGameBoard;
  final VoidCallback onDone;

  const _StatusFlashOverlay({
    required this.icon,
    required this.color,
    required this.isGameBoard,
    required this.onDone,
  });

  @override
  State<_StatusFlashOverlay> createState() => _StatusFlashOverlayState();
}

class _StatusFlashOverlayState extends State<_StatusFlashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 1.0).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.9).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 15,
      ),
    ]).animate(_ctrl);

    _fade = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 75),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 15,
      ),
    ]).animate(_ctrl);

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
    // The actual icon widget
    final iconWidget = IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Opacity(
            opacity: _fade.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.18),
                  border: Border.all(color: widget.color, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 48,
                ),
              ),
            ),
          );
        },
      ),
    );

    // ── Dynamic Positioning ──
    if (widget.isGameBoard) {
      // Game Mode: Bottom Left (above the item bar)
      return PositionedDirectional(
        start: 8,
        bottom: 150,
        child: iconWidget,
      );
    } else {
      // App Mode: Bottom Center (above the navigation bar)
      return Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 40,
        left: 0,
        right: 0,
        child: Center(child: iconWidget),
      );
    }
  }
}