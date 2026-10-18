import 'package:flutter/material.dart';

enum StatusFlashKind { success, error }

/// Floating success / fail indicator.
///
/// Renders only a large ✓ or ✗ icon in a coloured ring, anchored above
/// the game item bar (bottom-start). The optional [message] parameter is
/// accepted for API compatibility but intentionally not rendered.
class StatusFlash {
  StatusFlash._();

  static OverlayEntry? _current;

  static void success(BuildContext context, [String? message]) {
    _show(context, StatusFlashKind.success);
  }

  static void fail(BuildContext context, [String? message]) {
    _show(context, StatusFlashKind.error);
  }

  static void _show(BuildContext context, StatusFlashKind kind) {
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
  final VoidCallback onDone;

  const _StatusFlashOverlay({
    required this.icon,
    required this.color,
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
    return PositionedDirectional(
      // ── Anchored to the same edge as GameItemBar ──
      // GameItemBar is `start: 12, bottom: 12` with a 56-px toggle button.
      // Flash is 76 px, so `start: 2` centres it over the toggle:
      //   toggle centre = 12 + 28 = 40
      //   flash  centre =  2 + 38 = 40  ✓
      // `bottom: 80` sits it 12 px above the top of the toggle.
      start: 8,
      bottom: 150,
      child: IgnorePointer(
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
      ),
    );
  }
}