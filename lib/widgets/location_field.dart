import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

// Rounded text input for the start and destination fields.
// The focused field gets a primary-colored border, which shows the user which field the list below belongs to.
class LocationField extends StatelessWidget {
  const LocationField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.iconColor,
    this.iconSize = 24,
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final bool autofocus;                   // focus and open the keyboard when first shown
  final ValueChanged<String>? onChanged;  // fires on typing only

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F4F8),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        prefixIcon: Icon(icon, size: iconSize, color: iconColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
    );
  }
}