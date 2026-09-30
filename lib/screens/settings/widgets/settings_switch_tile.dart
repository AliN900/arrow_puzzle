import 'package:flutter/material.dart';

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textSecondary),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: accentColor,
        activeTrackColor: accentColor.withValues(alpha: 0.3),
      ),
    );
  }
}