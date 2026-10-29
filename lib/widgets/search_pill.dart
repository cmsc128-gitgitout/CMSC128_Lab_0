import 'package:flutter/material.dart';

// homescreen search bar
class SearchPill extends StatelessWidget {
  const SearchPill({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onTap,
  });

  // Placeholder text displayed when input is empty
  final String hint;

  // Controller to manage and retrieve typed text
  final TextEditingController? controller;

  // Callback triggered whenever the user types or edits text
  final ValueChanged<String>? onChanged;

  // Callback triggered when the text field gains focus or is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 2,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onTap: onTap,
          style: TextStyle(
            fontSize: 16,
            color: scheme.onSurface,
          ),

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: TextStyle(
              fontSize: 16,
              color: scheme.onSurfaceVariant.withOpacity(0.6),
            ),

            icon: Icon(Icons.search, color: scheme.onSurface),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}