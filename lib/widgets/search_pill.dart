import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

// homescreen search bar
class SearchPill extends StatelessWidget {
  const SearchPill({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  final String hint;                        // Placeholder text displayed when input is empty
  final TextEditingController? controller;  // Controller to manage and retrieve typed text
  final ValueChanged<String>? onChanged;    // Callback triggered whenever the user types or edits text
  final VoidCallback? onTap;                // Callback triggered when the text field gains focus or is tapped
  final bool readOnly;                      // Since there's a search pill in homescreen, but typing only happens in plan a trip screen

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black38,
      shape: const StadiumBorder(),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          onChanged: onChanged,
          onTap: onTap,
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600,
            color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5F6368),
            ),

            icon: const Icon(Icons.search, size: 26, color: AppTheme.primary),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}