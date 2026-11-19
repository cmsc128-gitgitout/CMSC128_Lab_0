import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'explore_screen.dart';
import 'network_screen.dart';
import 'chatbot_screen.dart';
import '../widgets/location_access_dialog.dart';

// Main screen: hosts the bottom navigation and the tab screens.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            LocationAccessDialog(onAllow: _requestLocationPermission),
      );
    });
  }

  Future<void> _requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (!mounted) return;

      switch (permission) {
        case LocationPermission.denied:
          _showLocationMessage('Location permission was denied.');
        case LocationPermission.deniedForever:
          _showLocationMessage(
            'Location access is blocked. Enable it in your device or browser settings.',
          );
        case LocationPermission.unableToDetermine:
          _showLocationMessage('Could not determine location permission.');
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          break;
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showLocationMessage(
        'Could not request location permission: ${error.message ?? error.code}',
      );
    }
  }

  void _showLocationMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static const _tabs = <Widget>[
    ExploreScreen(),
    NetworkScreen(),
    ChatbotScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps each tab's state when switching.
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_bus_outlined),
              selectedIcon: Icon(Icons.directions_bus),
              label: 'Routes',
            ),
            NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy),
              label: 'Larga',
            ),
          ],
        ),
      ),
    );
  }
}
