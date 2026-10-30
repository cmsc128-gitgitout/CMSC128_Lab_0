import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// Small map for inside a route card: zooms to fit the start and end stops.
// TODO (next sprint): mark the start and end on the map.
class RouteMiniMap extends StatelessWidget {
  const RouteMiniMap({
    super.key,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
  });

  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;

  @override
  Widget build(BuildContext context) {
    // Mapbox wants points as (longitude, latitude), the reverse of Google Maps.
    final start = Point(coordinates: Position(startLng, startLat));
    final end = Point(coordinates: Position(endLng, endLat));

    // A map in a card needs a fixed height, or Flutter can't size it.
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: MapWidget(
          styleUri: MapboxStyles.MAPBOX_STREETS,
          textureView: true,
          onMapCreated: (MapboxMap map) async {
            // Ask Mapbox for a camera that fits both points, with padding.
            final camera = await map.cameraForCoordinates(
              [start, end], // the two points to fit on screen
              MbxEdgeInsets(top: 30, left: 30, bottom: 30, right: 30), // space around the edges
              null, // bearing (rotation): keep default
              null, // pitch (tilt): keep default
            );
            await map.setCamera(camera);
          },
        ),
      ),
    );
  }
}