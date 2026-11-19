import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
//for reading route data
import 'package:provider/provider.dart';

import '../providers/transit_provider.dart';
import '../services/location_permission_service.dart';

import '../widgets/ai_assistant_button.dart';
import '../widgets/map_buttons.dart';
import '../widgets/iloilo_map.dart';
import '../widgets/search_pill.dart';
import '../widgets/suggested_routes_sheet.dart';
import 'plan_trip_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.onRequestLocationAccess});

  final VoidCallback onRequestLocationAccess;

  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  final _mapKey = GlobalKey<IloiloMapState>();
  final _locationPermissionService = LocationPermissionService();
  Position? _currentPosition;
  bool _locationAccessGranted = false;
  bool _isLocating = false;

  void setLocationAccessGranted(bool granted) {
    if (!mounted) return;
    setState(() {
      _locationAccessGranted = granted;
      if (!granted) _currentPosition = null;
    });
  }

  void _toast(BuildContext context, String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  Future<void> _showMyLocation() async {
    if (!_locationAccessGranted) {
      widget.onRequestLocationAccess();
      return;
    }
    await _locateCurrentUser(checkPermission: true);
  }

  Future<void> enableLocationAndCenter() async {
    if (!mounted) return;
    setLocationAccessGranted(true);
    await _locateCurrentUser(checkPermission: false);
  }

  Future<void> _locateCurrentUser({required bool checkPermission}) async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    try {
      if (checkPermission) {
        final outcome = await _locationPermissionService.requestAccess();
        if (!mounted) return;
        if (outcome != LocationAccessOutcome.granted) {
          setLocationAccessGranted(false);
          _showLocationAccessOutcome(outcome);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;

      final mapState = _mapKey.currentState;
      if (mapState == null) {
        _toast(context, 'The map is still loading. Try again shortly.');
        return;
      }
      final mapCentered = await mapState.centerOnLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (!mounted) return;
      if (!mapCentered) {
        _toast(context, 'The map is still loading. Try again shortly.');
        return;
      }

      setState(() => _currentPosition = position);
    } on LocationServiceDisabledException {
      if (mounted) {
        setLocationAccessGranted(false);
        _showLocationAccessOutcome(LocationAccessOutcome.servicesDisabled);
      }
    } on PermissionDeniedException {
      if (mounted) {
        setLocationAccessGranted(false);
        _showLocationPermissionSettings();
      }
    } on TimeoutException {
      if (mounted) {
        _toast(
          context,
          "Couldn't get your location. Check your GPS signal and try again.",
        );
      }
    } on PlatformException catch (error) {
      if (mounted) {
        _toast(
          context,
          'Could not get or display your location: ${error.message ?? error.code}',
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showLocationAccessOutcome(LocationAccessOutcome outcome) {
    switch (outcome) {
      case LocationAccessOutcome.granted:
        return;
      case LocationAccessOutcome.servicesDisabled:
        if (kIsWeb) {
          _toast(context, 'Enable location services in your browser settings.');
        } else {
          _toast(
            context,
            'Location services are turned off. Enable them to use location.',
            action: SnackBarAction(
              label: 'Settings',
              onPressed: _openLocationSettings,
            ),
          );
        }
      case LocationAccessOutcome.denied:
        _toast(context, 'Location permission was denied.');
      case LocationAccessOutcome.deniedForever:
        _showLocationPermissionSettings();
      case LocationAccessOutcome.unableToDetermine:
        _toast(context, 'Could not determine location permission.');
    }
  }

  void _showLocationPermissionSettings() {
    if (kIsWeb) {
      _toast(context, 'Enable location access in your browser settings.');
    } else {
      _toast(
        context,
        'Location access is blocked. Enable it in app settings.',
        action: SnackBarAction(
          label: 'App settings',
          onPressed: _openAppSettings,
        ),
      );
    }
  }

  Future<void> _openLocationSettings() async {
    try {
      final opened = await Geolocator.openLocationSettings();
      if (mounted && !opened) {
        _toast(
          context,
          'Could not open location settings. Enable them manually.',
        );
      }
    } on PlatformException catch (error) {
      if (mounted) {
        _toast(
          context,
          'Could not open location settings: ${error.message ?? error.code}',
        );
      }
    }
  }

  Future<void> _openAppSettings() async {
    try {
      final opened = await Geolocator.openAppSettings();
      if (mounted && !opened) {
        _toast(
          context,
          'Could not open app settings. Enable location access manually.',
        );
      }
    } on PlatformException catch (error) {
      if (mounted) {
        _toast(
          context,
          'Could not open app settings: ${error.message ?? error.code}',
        );
      }
    }
  }

  void _showSuggestedRoutes() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (_) => const SuggestedRoutesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    //read list of routes then awlays sync with transitprovider updates
    final routes = context.watch<TransitProvider>().routes;
    return Stack(
      children: [
        // Layer 1: map
        Positioned.fill(
          child: IloiloMap(
            key: _mapKey,
            routes: routes,
            showLocationPuck: _locationAccessGranted,
          ),
        ), //pass livee data to map
        // Map controls sit below the route sheet.
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: const Color(0xFF1261A6),
                  elevation: 6,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Test suggested routes',
                    onPressed: _showSuggestedRoutes,
                    icon: const Icon(Icons.alt_route, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                AiAssistantButton(
                  onPressed: () => _toast(context, 'TODO: open AI assistant'),
                ),
              ],
            ),
          ),
        ),

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
                  active: _currentPosition != null,
                  onPressed: _showMyLocation,
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

        // Search bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
            child: SearchPill(
              hint: 'Where to?',
              readOnly: true, // tap target only; typing happens on the plan trip screen
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      PlanTripScreen(locEnabled: _currentPosition != null),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
