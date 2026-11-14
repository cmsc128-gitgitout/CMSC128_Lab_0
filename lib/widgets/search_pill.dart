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