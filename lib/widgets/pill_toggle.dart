import 'package:flutter/material.dart';

// Row of pill buttons where one is selected (used for tabs and filter chips).
class PillToggle extends StatelessWidget {
  const PillToggle({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.selectedColor = Colors.black,
    this.selectedTextColor = Colors.white,
    this.fontSize = 13,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color selectedColor;
  final Color selectedTextColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _Pill(
              label: labels[i],
              selected: i == selectedIndex,
              selectedColor: selectedColor,
              selectedTextColor: selectedTextColor,
              fontSize: fontSize,
              onTap: () => onChanged(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.selectedTextColor,
    required this.fontSize,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final Color selectedTextColor;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? selectedColor : const Color(0xFFE6E6E6),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: selected ? selectedTextColor : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
