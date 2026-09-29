import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import '../../main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Accent colors for the picker
  static const List<Color> accentColors = [
    Color(0xFF6C4CF1), // Purple (Default)
    Color(0xFF00C853), // Green
    Color(0xFF448AFF), // Blue
    Color(0xFFFF5A5F), // Red/Pink
    Color(0xFFFFD54F), // Yellow
    Color(0xFF00BCD4), // Cyan
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressRepositoryProvider);
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // --- APPEARANCE SECTION (Theme & Accent) ---
            _buildSectionHeader('APPEARANCE', textSecondary),
            _buildCard(
              cardColor: cardColor,
              children: [
                // Theme Toggle
                ListTile(
                  leading: Icon(Icons.dark_mode_outlined, color: textSecondary),
                  title: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).state =
                      value ? ThemeMode.dark : ThemeMode.light;
                    },
                    activeThumbColor: accentColor,
                    activeTrackColor: accentColor.withValues(alpha: 0.3),
                  ),
                ),
                Divider(height: 1, color: textSecondary.withValues(alpha: 0.2)),
                // Accent Picker
                // Accent Picker (Responsive)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Fixed label on the left
                      Icon(Icons.color_lens_outlined, color: textSecondary, size: 24),
                      const SizedBox(width: 16),
                      Text(
                        'Accent Color',
                        style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
                      ),
                      const SizedBox(width: 12),
                      // Scrollable colors on the right
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true, // Starts scrolled to the right end
                          child: Row(
                            children: accentColors.map((color) {
                              final isSelected = accentColor.value == color.value;
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: GestureDetector(
                                  onTap: () =>
                                  ref.read(accentColorProvider.notifier).state = color,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(color: textPrimary, width: 2)
                                          : null,
                                    ),
                                    child: isSelected
                                        ? Icon(Icons.check,
                                        size: 16,
                                        color: color.computeLuminance() > 0.5
                                            ? Colors.black
                                            : Colors.white)
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- AUDIO & HAPTICS SECTION ---
            _buildSectionHeader('AUDIO & HAPTICS', textSecondary),
            _buildCard(
              cardColor: cardColor,
              children: [
                _buildSwitchTile(
                  icon: Icons.volume_up_outlined,
                  title: 'Sound effects',
                  value: progress.soundEnabled ?? true,
                  onChanged: (v) => ref.read(progressRepositoryProvider).toggleSound(),
                  accentColor: accentColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                Divider(height: 1, color: textSecondary.withValues(alpha: 0.2)),
                _buildSwitchTile(
                  icon: Icons.music_note_outlined,
                  title: 'Music',
                  value: progress.musicEnabled ?? true, // Fallback
                  onChanged: (v) => ref.read(progressRepositoryProvider).toggleMusic(),
                  accentColor: accentColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                Divider(height: 1, color: textSecondary.withValues(alpha: 0.2)),
                _buildSwitchTile(
                  icon: Icons.vibration_outlined,
                  title: 'Vibration',
                  value: progress.hapticsEnabled,
                  onChanged: (_) => ref.read(progressRepositoryProvider).toggleHaptics(),
                  accentColor: accentColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- ARROW SPEED SECTION ---
            _buildSectionHeader('ARROW SPEED', textSecondary),
            _buildCard(
              cardColor: cardColor,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.speed_outlined, color: textSecondary, size: 24),
                          const SizedBox(width: 16),
                          Text('Escape speed', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                          const Spacer(),
                          Text(
                            progress.arrowSpeed == 0 ? 'Slow' : progress.arrowSpeed == 1 ? 'Normal' : 'Fast',
                            style: TextStyle(fontWeight: FontWeight.bold, color: accentColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: (progress.arrowSpeed ?? 0).toDouble(), // Add to repo
                        min: 0,
                        max: 2,
                        divisions: 2,
                        activeColor: accentColor,
                        onChanged: (value) {
                          ref.read(progressRepositoryProvider).setArrowSpeed(value.toInt()); // Add to repo
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- GENERAL SECTION ---
            _buildSectionHeader('GENERAL', textSecondary),
            _buildCard(
              cardColor: cardColor,
              children: [
                _buildNavTile(
                  icon: Icons.share_outlined,
                  title: 'Share with friends',
                  onTap: () { /* TODO: Share logic */ },
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                Divider(height: 1, color: textSecondary.withValues(alpha: 0.2)),
                _buildNavTile(
                  icon: Icons.star_outline_rounded,
                  title: 'Rate the app',
                  onTap: () { /* TODO: Rate logic */ },
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                Divider(height: 1, color: textSecondary.withValues(alpha: 0.2)),
                _buildNavTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Contact support',
                  onTap: () { /* TODO: Contact logic */ },
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- ABOUT SECTION ---
            _buildSectionHeader('ABOUT', textSecondary),
            _buildCard(
              cardColor: cardColor,
              children: [
                _buildNavTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy',
                  onTap: () { /* TODO: Privacy logic */ },
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                Divider(height: 1, color: textSecondary.withValues(alpha: 0.2)),
                _buildNavTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () { /* TODO: Terms logic */ },
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- APP VERSION ---
            Center(
              child: Column(
                children: [
                  Text(
                    'Arrows — Puzzle Escape',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0 (1)',
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard({required Color cardColor, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color accentColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return ListTile(
      leading: Icon(icon, color: textSecondary),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: accentColor,
        activeTrackColor: accentColor.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return ListTile(
      leading: Icon(icon, color: textSecondary),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
      trailing: Icon(Icons.chevron_right_rounded, color: textSecondary),
      onTap: onTap,
    );
  }
}