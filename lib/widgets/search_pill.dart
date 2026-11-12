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
    // final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 28
        side: const BorderSide(color: Colors.black, width: 1.5),
      ),
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
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF666666),
            ),

            icon: const Icon(Icons.search, size: 28, color: Colors.black),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}