import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

// Rounded square button floating over the map.
class MapButton extends StatelessWidget {
  const MapButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? AppTheme.primary : const Color(0xFFF5F9FF),
        elevation: 4,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(
              icon, 
              size: 30, 
              color: active ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}