import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

// A row in the recents or suggestions list.
// Recents get a clock icon, everything else gets a pin.
class PlaceTile extends StatelessWidget {
  const PlaceTile({
    super.key,
    required this.name,
    required this.detail,
    required this.onTap,
    this.isRecent = false,
  });

  final String name;
  final String detail; // second line under the name
  final bool isRecent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFF1F4F8),
        child: Icon(
          isRecent ? Icons.history : Icons.location_on_outlined,
          color: isRecent ? AppTheme.primary : const Color(0xFFD32F2F),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(detail),
      onTap: onTap,
    );
  }
}