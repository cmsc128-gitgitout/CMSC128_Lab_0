import 'package:flutter/material.dart';

import '../widgets/iloilo_map.dart';

// Choose on map screen: the user pans the map under a fixed center pin,
// then confirms the location. Skeleton only: no selected location yet.
class ChooseOnMapScreen extends StatelessWidget {
  const ChooseOnMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pin your destination')),
      body: Stack(
        children: [
          // Layer 1: map
          const Positioned.fill(child: IloiloMap()),

          // Layer 2: fixed pin in the center of the screen
          const Center(child: Icon(Icons.location_on, size: 48)),

          // Layer 3: confirm button (just goes back for now)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Confirm'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}