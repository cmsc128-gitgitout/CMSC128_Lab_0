import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../services/geocoding_service.dart';
import '../widgets/iloilo_map.dart';

// Choose on map screen: the user pans the map under a fixed pin at the center.
// On confirm, the map's center coordinates are returned to the caller via Navigator.pop.
class ChooseOnMapScreen extends StatefulWidget {
  const ChooseOnMapScreen({super.key});

  @override
  State<ChooseOnMapScreen> createState() => _ChooseOnMapScreenState();
}

class _ChooseOnMapScreenState extends State<ChooseOnMapScreen> {
  // set once the map is created; used to read the camera on confirm.
  MapboxMap? _map;

  // reads the current map center (the point under the pin)
  // then returns it to the previous screen as a (lat, lng) record.
  bool _loading = false;

  Future<void> _confirm() async {
    final camera = await _map?.getCameraState();
    if (camera == null || !mounted) return;
    setState(() => _loading = true);

    final pos = camera.center.coordinates;
    final lat = pos.lat.toDouble();
    final lng = pos.lng.toDouble();
    final name = await _poiNameAt(camera.center) ??
      await GeocodingService.reverse(lat, lng) ??
      'Pinned location';

    if (!mounted) return;
    Navigator.pop(context, (lat: lat, lng: lng, name: name));
  }

  // Name of the POI label under the pin, or null if none is close enough.
  Future<String?> _poiNameAt(Point center) async {
    final map = _map;
    if (map == null) return null;

    final px = await map.pixelForCoordinate(center);
    const r = 24.0; // search radius in screen pixels around the pin
    final box = ScreenBox(
      min: ScreenCoordinate(x: px.x - r, y: px.y - r),
      max: ScreenCoordinate(x: px.x + r, y: px.y + r),
    );

    final hits = await map.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenBox(box),
      RenderedQueryOptions(layerIds: ['poi-label']), // POI layer in Streets style
    );

    for (final hit in hits) {
      final props = hit?.queriedFeature.feature['properties'];
      final name = props is Map ? props['name'] : null;
      if (name is String && name.isNotEmpty) return name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose on map')),
      body: Stack(
        children: [
          // Layer 1: map (bounds and style are set inside IloiloMap)
          IloiloMap(
            zoom: 14,
            onMapCreated: (map) => _map = map,
          ),

          // Layer 2: fixed center pin. 
          // IgnorePointer lets touches pass thru to the map so panning still works under the pin.
          // The bottom padding shifts the icon up so its tip, not its middle, sits on the exact map center.
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(Icons.location_on, size: 48, color: Colors.red),
              ),
            ),
          ),

          // Layer 3: confirm button pinned to the bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: FilledButton(
                onPressed: _loading ? null : _confirm,
                child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}