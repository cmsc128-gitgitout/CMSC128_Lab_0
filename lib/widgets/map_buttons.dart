import 'package:flutter/material.dart';

// Rounded square button floating over the map.
class MapButton extends StatelessWidget {
  const MapButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF5F9FF),
        elevation: 4,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(icon, size: 30, color: Colors.black),
          ),
        ),
      ),
    );
  }
}