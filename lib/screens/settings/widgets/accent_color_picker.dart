import 'package:flutter/material.dart';

class AccentColorPicker extends StatelessWidget {
  final List<Color> accentColors;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final Color textPrimary;
  final Color textSecondary;

  const AccentColorPicker({
    super.key,
    required this.accentColors,
    required this.selectedColor,
    required this.onColorSelected,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.color_lens_outlined, color: textSecondary, size: 24),
          const SizedBox(width: 16),
          Text(
            'Accent Color',
            style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: accentColors.map((color) {
                  final isSelected =
                      selectedColor.toARGB32() == color.toARGB32();
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () => onColorSelected(color),
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
                            ? Icon(
                          Icons.check,
                          size: 16,
                          color: color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        )
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
    );
  }
}