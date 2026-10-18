import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/game_mode.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../screens/game/game_screen.dart';
import 'home_hero_card.dart';

class ZenModeCard extends ConsumerWidget {
  const ZenModeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);

    return HomeHeroCard(
      label: strings.zenModeLabel,       // "RELAX" / "MODE"
      title: strings.zenModeTitle,       // "Zen Mode"
      subtitle: strings.zenModeSubtitle, // one-liner description
      icon: Icons.self_improvement_rounded,
      iconColor: const Color(0xFF00C853),
      onTap: () {
        final progress = ref.read(progressRepositoryProvider);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(
              level: progress.currentLevel,
              gameMode: GameMode.zen,
            ),
          ),
        );
      },
    );
  }
}