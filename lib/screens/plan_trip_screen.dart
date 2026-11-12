import 'package:flutter/material.dart';

// Plan your trip screen: start and destination inputs plus location pickers.
// Skeleton only: no state, no real search yet.
class PlanTripScreen extends StatelessWidget {
  const PlanTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan your trip')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          // Start location input
          TextField(decoration: InputDecoration(hintText: 'Start location')),
          SizedBox(height: 12),

          // Destination input
          TextField(decoration: InputDecoration(hintText: 'Where to?')),
          SizedBox(height: 12),

          // Opens the map pin picker (wired up in a later commit)
          ListTile(
            leading: Icon(Icons.map_outlined),
            title: Text('Choose on map'),
          ),

          // List sections (placeholders)
          Text('SUGGESTIONS'),
          Text('RECENT'),
        ],
      ),
    );
  }
}