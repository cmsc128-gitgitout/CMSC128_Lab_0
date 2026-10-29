import 'package:flutter/material.dart';

/// Marker showing the user's initial. Placeholder until GPS is wired.
class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({super.key, required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFB04FD0),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2F8CFF), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
