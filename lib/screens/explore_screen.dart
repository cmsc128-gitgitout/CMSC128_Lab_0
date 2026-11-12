import 'package:flutter/material.dart';

import '../widgets/ai_assistant_button.dart';
import '../widgets/iloilo_map.dart';
import '../widgets/search_pill.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1: map 
        const Positioned.fill(child: IloiloMap()),

        // Layer 2: search bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SearchPill(
              hint: 'Where to?',
              onTap: () => _toast(context, 'TODO: open destination search'),
            ),
          ),
        ),

        // Layer 3: AI assistant button
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AiAssistantButton(
              onPressed: () => _toast(context, 'TODO: open AI assistant'),
            ),
          ),
        ),

        // Layer 4: locate and directions buttons
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapButton(
                  icon: Icons.my_location,
                  tooltip: 'My location',
                  onPressed: () => _toast(context, 'TODO: center on location'),
                ),
                const SizedBox(height: 12),
                _MapButton(
                  icon: Icons.directions_outlined,
                  tooltip: 'Directions',
                  onPressed: () => _toast(context, 'TODO: open directions'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Rounded square button floating over the map
class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF5F9FF),
        elevation: 4,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
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