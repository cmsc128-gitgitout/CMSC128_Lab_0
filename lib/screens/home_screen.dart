import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'explore_screen.dart';
import 'network_screen.dart';
import 'chatbot_screen.dart';
import '../widgets/location_access_dialog.dart';
import '../services/location_permission_service.dart';

// Main screen: hosts the bottom navigation and the tab screens.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _locationPermissionService = LocationPermissionService();
  final _exploreKey = GlobalKey<ExploreScreenState>();
  bool _locationDialogVisible = false;
  bool _locationRequestInProgress = false;
  late final _tabs = <Widget>[
    ExploreScreen(
      key: _exploreKey,
      onRequestLocationAccess: _showLocationAccessDialog,
    ),
    const NetworkScreen(),
    const ChatbotScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_showLocationAccessDialog());
    });
  }

  Future<void> _showLocationAccessDialog() async {
    if (!mounted || _locationDialogVisible || _locationRequestInProgress) {
      return;
    }
    _locationDialogVisible = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            LocationAccessDialog(onAllow: _requestLocationPermission),
      );
    } finally {
      _locationDialogVisible = false;
    }
  }

  Future<void> _requestLocationPermission() async {
    if (_locationRequestInProgress) return;
    _locationRequestInProgress = true;
    try {
      final outcome = await _locationPermissionService.requestAccess();
      if (!mounted) return;

      switch (outcome) {
        case LocationAccessOutcome.servicesDisabled:
          _exploreKey.currentState?.setLocationAccessGranted(false);
          if (kIsWeb) {
            _showLocationMessage(
              'Location services are turned off. Enable location in your browser settings.',
            );
          } else {
            _showLocationMessage(
              'Location services are turned off. Enable them to use location.',
              action: SnackBarAction(
                label: 'Settings',
                onPressed: _openLocationSettings,
              ),
            );
          }
        case LocationAccessOutcome.denied:
          _exploreKey.currentState?.setLocationAccessGranted(false);
          _showLocationMessage('Location permission was denied.');
        case LocationAccessOutcome.deniedForever:
          _exploreKey.currentState?.setLocationAccessGranted(false);
          if (kIsWeb) {
            _showLocationMessage(
              'Location access is blocked. Enable it in your browser settings.',
            );
          } else {
            _showLocationMessage(
              'Location access is blocked. Enable it in app settings.',
              action: SnackBarAction(
                label: 'App settings',
                onPressed: _openAppSettings,
              ),
            );
          }
        case LocationAccessOutcome.unableToDetermine:
          _exploreKey.currentState?.setLocationAccessGranted(false);
          _showLocationMessage('Could not determine location permission.');
        case LocationAccessOutcome.granted:
          final explore = _exploreKey.currentState;
          if (explore != null) await explore.enableLocationAndCenter();
          break;
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      _exploreKey.currentState?.setLocationAccessGranted(false);
      _showLocationMessage(
        'Could not request location permission: ${error.message ?? error.code}',
      );
    } finally {
      _locationRequestInProgress = false;
    }
  }

  Future<void> _openLocationSettings() async {
    try {
      final opened = await Geolocator.openLocationSettings();
      if (!mounted) return;
      if (!opened) {
        _showLocationMessage(
          'Could not open location settings. Enable location services manually.',
        );
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showLocationMessage(
        'Could not open location settings: ${error.message ?? error.code}',
      );
    }
  }

  Future<void> _openAppSettings() async {
    try {
      final opened = await Geolocator.openAppSettings();
      if (!mounted) return;
      if (!opened) {
        _showLocationMessage(
          'Could not open app settings. Enable location access in device settings.',
        );
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showLocationMessage(
        'Could not open app settings: ${error.message ?? error.code}',
      );
    }
  }

  void _showLocationMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

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
