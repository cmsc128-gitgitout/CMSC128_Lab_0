import 'package:flutter/material.dart';

import '../widgets/ai_assistant_button.dart';
import '../widgets/map_buttons.dart';
import '../widgets/iloilo_map.dart';
import '../widgets/search_pill.dart';
import 'plan_trip_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Placeholder: replace with a real permission check in feat/user-location.
  bool _locationGranted = false;

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
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
            child: SearchPill(
              hint: 'Where to?',
              // Open the plan trip screen
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PlanTripScreen()),
              ),
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
                MapButton(
                  icon: Icons.my_location,
                  tooltip: 'My location',

                  // Temporary: toggles the glow to indicate active button
                  active: _locationGranted,
                  onPressed: () => setState(() => _locationGranted = !_locationGranted),
                  // onPressed: () => _toast(context, 'TODO: center on location'),
                  
                ),
                const SizedBox(height: 12),
                MapButton(
                  icon: Icons.directions_outlined,
                  tooltip: 'Directions',
                  // Open the plan trip screen
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlanTripScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}