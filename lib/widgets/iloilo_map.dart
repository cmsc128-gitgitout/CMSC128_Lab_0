import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class IloiloMap extends StatelessWidget {
  const IloiloMap({super.key});

  @override
  Widget build(BuildContext context) {
    return MapWidget(
        styleUri: MapboxStyles.MAPBOX_STREETS,
        textureView: true,
        viewport: CameraViewportState(
          center: Point(coordinates: Position(122.5621, 10.7202)), // long, lat (Iloilo City)
          zoom: 12,
        ),
        onMapCreated: (MapboxMap map) {
          map.setBounds(
            CameraBoundsOptions(
              bounds: CoordinateBounds(
                southwest: Point(coordinates: Position(122.47, 10.64)), 
                northeast: Point(coordinates: Position(122.62, 10.78)), 
                infiniteBounds: false,
              ),
              minZoom: 11,
              maxZoom: 18,
            ),
          );
        },
    );
  }
}
