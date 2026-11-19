import 'package:flutter/material.dart';

// Small uppercase heading above a list (e.g. RECENT, SUGGESTIONS).
// Optional trailing widget sits on the right (e.g. a "Clear" button).
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5F6368),
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}