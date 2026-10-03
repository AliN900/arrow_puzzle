import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../core/app_colors.dart';

class LivesBar extends HookWidget {
  final int lives;
  final int maxLives;

  const LivesBar({super.key, required this.lives, required this.maxLives});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    // Start the looping animation once on mount
    useEffect(() {
      controller.repeat(reverse: true);
      return null;
    }, const []);

    // Adjust speed when lives drop to 1
    useEffect(() {
      controller.duration = lives <= 1
          ? const Duration(milliseconds: 400)
          : const Duration(milliseconds: 1000);
      return null;
    }, [lives]);

    final scaleAnim = useMemoized(
          () => Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
      [controller],
    );

    final isLowLives = lives == 1;
    final surfaceLight = AppColors.surfaceLight(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (i) {
        final isFull = i < lives;

        final heartWidget = Stack(
          alignment: Alignment.center,
          children: [
            if (isFull)
              Icon(
                Icons.favorite,
                color: isLowLives
                    ? Colors.redAccent.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.15),
                size: 27,
              ),
            if (isFull)
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isLowLives
                      ? [const Color(0xFFFF5252), const Color(0xFFFF1744)]
                      : [Colors.white, const Color(0xFFB0B0B0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 25,
                ),
              )
            else
              Icon(
                Icons.favorite_border,
                color: surfaceLight,
                size: 24,
              ),
            if (isFull)
              Positioned(
                top: 5,
                left: 5,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
              child: child,
            ),
            child: isFull
                ? ScaleTransition(
              key: ValueKey('heart_${i}_full'),
              scale: scaleAnim,
              child: heartWidget,
            )
                : SizedBox(
              key: ValueKey('heart_${i}_empty'),
              child: heartWidget,
            ),
          ),
        );
      }),
    );
  }
}