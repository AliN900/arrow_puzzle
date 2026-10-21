import 'package:flutter/material.dart';

/// Small floating badge that shows the remaining taps before the active
/// leaving arrow force-fires. Pops on every decrement to draw attention.
class LeavingArrowCounter extends StatefulWidget {
  final int count;
  final int max;
  final Color color;
  final VoidCallback? onTap;

  const LeavingArrowCounter({
    super.key,
    required this.count,
    required this.max,
    required this.color,
    this.onTap,

  });

  @override
  State<LeavingArrowCounter> createState() => _LeavingArrowCounterState();
}

class _LeavingArrowCounterState extends State<LeavingArrowCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late int _prevCount;

  @override
  void initState() {
    super.initState();
    _prevCount = widget.count;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    // 1.0 → 0.67 → 1.0 (shrink-pop), as requested.
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.67)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.67, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.forward(from: 0); // pop on first appearance
  }

  @override
  void didUpdateWidget(covariant LeavingArrowCounter old) {
    super.didUpdateWidget(old);
    if (widget.count != _prevCount) {
      _prevCount = widget.count;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.65),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 15,
                color: widget.color,
              ),
              const SizedBox(width: 5),
              Text(
                '${widget.count}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: widget.color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
