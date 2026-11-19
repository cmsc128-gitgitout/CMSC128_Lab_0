import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../models/transit_route.dart';

class IloiloMap extends StatefulWidget {
  const IloiloMap({super.key, this.routes = const []});
  final List<TransitRoute> routes;

  @override
  IloiloMapState createState() => IloiloMapState();
}

class IloiloMapState extends State<IloiloMap> {
  MapboxMap? _map;
  bool _mapReady = false;
  bool _styleLoaded = false;
  //used for drawing map since mapbox need data and how it will look
  static const _sourceId = 'routes-source'; //for GeoJsonSource
  static const _layerId = 'routes-line';

  static const List<String> _routeColors = [
    '#800080', //  red
    '#1565C0', // Blue
    '#FFFF00',
    '#00FF00',
  ];

  Future<bool> centerOnLocation({
    required double latitude,
    required double longitude,
  }) async {
    final map = _map;
    if (map == null || !_mapReady) return false;

    await map.setBounds(
      CameraBoundsOptions(bounds: InfiniteCoordinateBounds()),
    );
    await map.setCamera(
      CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: 15,
      ),
    );
    return true;
  }

  ////redraw whenever transitRoute passes updated route list
  @override
  void didUpdateWidget(covariant IloiloMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routes != widget.routes) {
      _drawRoutes();
    }
  }

  //convert transitroute obj to geojson string
  String _routesGeoJson() => jsonEncode({
    'type': 'FeatureCollection',
    'features': [
      for (int i = 0; i < widget.routes.length; i++)
        if (widget.routes[i].path.length >= 2)
          {
            'type': 'Feature',
            'properties': {
              'route_no': widget.routes[i].routeNo,
              'color': _routeColors[i % _routeColors.length],
            },
            'geometry': {
              'type': 'LineString',
              'coordinates': widget.routes[i].path,
            },
          },
    ],
  });

  //use drawing properties and coords
  Future<void> _drawRoutes() async {
    final map = _map;
    if (map == null || !_styleLoaded) return;

    // debugPrint('IloiloMap drawing ${widget.routes.length} routes');
    // for (final r in widget.routes) {
    //   debugPrint('${r.routeNo}: ${r.path.length} points');
    // }

    try {
      final style = map.style;
      //checks if route was alr there then removes before drawing
      if (await style.styleSourceExists(_sourceId)) {
        await style.removeStyleLayer(_layerId);
        await style.removeStyleSource(_sourceId);
      }
      await style.addSource(
        GeoJsonSource(id: _sourceId, data: _routesGeoJson()),
      );
      await style.addLayer(
        LineLayer(
          id: _layerId,
          sourceId: _sourceId,
          lineColorExpression: ['get', 'color'],
          lineWidth: 4.0,
          lineCap: LineCap.ROUND,
          lineJoin: LineJoin.ROUND,
        ),
      );
    } catch (e) {
      debugPrint('drawing unsuccessful $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: MapboxStyles.MAPBOX_STREETS,
      viewport: CameraViewportState(
        center: Point(coordinates: Position(122.5621, 10.7202)), // lng, lat
        zoom: 12,
      ),
      onMapCreated: (MapboxMap map) async {
        _map = map;
        await map.setBounds(
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
        _mapReady = true;
      },
      //dDraw only after the style is ready
      onStyleLoadedListener: (_) {
        _styleLoaded = true;
        _drawRoutes();
      },
    );
  }
}
