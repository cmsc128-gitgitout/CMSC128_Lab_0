import 'package:flutter/material.dart';

import '../widgets/ai_assistant_button.dart';
import '../widgets/map_placeholder.dart';
import '../widgets/search_pill.dart';

// Explore tab (map). The map layer is a placeholder for now.
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
        // Layer 1: map (swap MapPlaceholder with the real map widget later)
        const Positioned.fill(child: MapPlaceholder()),

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
      ],
    );
  }
}