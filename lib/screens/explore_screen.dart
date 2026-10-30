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
      ],
    );
  }
}