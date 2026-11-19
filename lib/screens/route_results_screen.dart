import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/boarding_point.dart';
import '../models/trip_option.dart';
import '../providers/transit_provider.dart';
import '../utils/app_theme.dart';
import '../utils/route_finder.dart';
import '../widgets/iloilo_map.dart';
import '../widgets/suggested_routes_sheet.dart';
import '../utils/trip_colors.dart';

// Shown after the user picked a start and a destination: map with all trips drawn, a top card, and the list of trips.
class RouteResultsScreen extends StatefulWidget {
  const RouteResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
  });

  final BoardingPoint origin;
  final BoardingPoint destination;

  @override
  State<RouteResultsScreen> createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends State<RouteResultsScreen> {
  static const _startHex = '#1261A6';
  static const _endHex = '#D32F2F';

  late BoardingPoint _origin;
  late BoardingPoint _destination;

  List<TripOption> _options = const [];

  // What the map draws. Built only when the options change.
  List<MapLine> _lines = const [];
  List<MapMarker> _markers = const [];

  @override
  void initState() {
    super.initState();
    _origin = widget.origin;
    _destination = widget.destination;
    _compute();
  }

  // Finds the trips for the current start/destination. Call inside setState when the screen is already showing.
  void _compute() {
    final transit = context.read<TransitProvider>();
    _options = findTrips(
      origin: _origin,
      destination: _destination,
      routes: transit.routes,
      stopById: transit.stopById,
      modeName: transit.modeName,
    );
    _buildMapData();
  }

  // Every option is drawn at once, in the same color as its card stripe.
  void _buildMapData() {
    _lines = [
      for (var i = _options.length - 1; i >= 0; i--)
        MapLine(coordinates: _options[i].path, colorHex: tripColorHex(i)),
    ];
    _markers = [
      MapMarker(lat: _origin.lat, lng: _origin.lng, colorHex: _startHex),
      MapMarker(lat: _destination.lat, lng: _destination.lng, colorHex: _endHex),
    ];
  }

  void _swap() {
    setState(() {
      final tmp = _origin;
      _origin = _destination;
      _destination = tmp;
      _compute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // Map: draws every option and the two stops.
          Positioned.fill(
            child: IloiloMap(
              lines: _lines,
              markers: _markers,
              // Keep the trips inside the part of the map the UI does not cover.
              cameraPadding: EdgeInsets.fromLTRB(
                40,
                topInset + 120,
                40,
                size.height * 0.6,
              ),
            ),
          ),

          // Top card: back, start / destination, swap.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _TripHeader(
                  origin: _origin.name,
                  destination: _destination.name,
                  onBack: () => Navigator.of(context).maybePop(),
                  onSwap: _swap,
                ),
              ),
            ),
          ),

          if (_options.isEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: _NoRouteCard(
                origin: _origin.name,
                destination: _destination.name,
              ),
            )
          else
            Positioned.fill(
              child: SuggestedRoutesSheet(
                // New options = fresh sheet (selection and sort reset).
                key: ObjectKey(_options),
                options: _options,
                onSelected: (o) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('TODO: Route details screen.')),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TripHeader extends StatelessWidget {
  const _TripHeader({
    required this.origin,
    required this.destination,
    required this.onBack,
    required this.onSwap,
  });

  final String origin;
  final String destination;
  final VoidCallback onBack;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StopRow(
                    icon: Icons.circle,
                    size: 10,
                    color: AppTheme.primary,
                    name: origin,
                  ),
                  const SizedBox(height: 8),
                  _StopRow(
                    icon: Icons.circle,
                    size: 10,
                    color: const Color(0xFFD32F2F),
                    name: destination,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Swap start and destination',
              icon: const Icon(Icons.swap_vert),
              onPressed: onSwap,
            ),
          ],
        ),
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.icon,
    required this.size,
    required this.color,
    required this.name,
  });

  final IconData icon;
  final double size;
  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: size, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _NoRouteCard extends StatelessWidget {
  const _NoRouteCard({required this.origin, required this.destination});

  final String origin;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.directions_off_outlined,
                  size: 36, color: Color(0xFF667085)),
              const SizedBox(height: 12),
              const Text(
                'No route found',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'No ride connects $origin to $destination. '
                'Try swapping them or picking a different stop.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF475467)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}