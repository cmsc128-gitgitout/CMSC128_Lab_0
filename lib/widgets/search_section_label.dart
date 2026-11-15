import 'package:flutter/material.dart';

// Small uppercase heading above a list (e.g. RECENT, SUGGESTIONS).
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5F6368),
        ),
      ),
    );
  }
}