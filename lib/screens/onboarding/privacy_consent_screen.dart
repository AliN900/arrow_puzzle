import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/audio_haptic_helper.dart';
import '../../main.dart';

class PrivacyConsentScreen extends ConsumerWidget {
  final VoidCallback onAccepted;

  const PrivacyConsentScreen({super.key, required this.onAccepted});

  static const String _ppUrl =
      'https://ahbdev.dev/arrow-puzzle/privacy.html';
  static const String _termsUrl =
      'https://ahbdev.dev/arrow-puzzle/terms.html';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final bg = AppColors.background(context);
    final card = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),

                        Center(
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                'assets/icon.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          strings.privacyWelcomeTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          strings.privacyWelcomeSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _bullet(
                                Icons.storage_outlined,
                                strings.privacyBulletLocal,
                                textPrimary,
                                accent,
                              ),
                              const SizedBox(height: 14),
                              _bullet(
                                Icons.cloud_outlined,
                                strings.privacyBulletCloud,
                                textPrimary,
                                accent,
                              ),
                              const SizedBox(height: 14),
                              _bullet(
                                Icons.campaign_outlined,
                                strings.privacyBulletAds,
                                textPrimary,
                                accent,
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              TextButton(
                                onPressed: () {
                                  AudioHapticHelper.playClick();
                                  launchUrl(
                                    Uri.parse(_ppUrl),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                child: Text(
                                  strings.privacyPolicyLink,
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: accent,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  AudioHapticHelper.playClick();
                                  launchUrl(
                                    Uri.parse(_termsUrl),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                child: Text(
                                  strings.privacyTermsLink,
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () async {
                              AudioHapticHelper.playClick();
                              await ref
                                  .read(progressRepositoryProvider)
                                  .acceptPrivacyPolicy();
                              onAccepted();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              strings.privacyAcceptButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.privacyAgreeFooter,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bullet(
      IconData icon,
      String text,
      Color textPrimary,
      Color accent,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: textPrimary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}