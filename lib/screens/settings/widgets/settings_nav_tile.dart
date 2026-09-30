import 'package:flutter/material.dart';

class SettingsNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color textSecondary;

  const SettingsNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
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
      trailing: Icon(Icons.chevron_right_rounded, color: textSecondary),
      onTap: onTap,
    );
  }
}