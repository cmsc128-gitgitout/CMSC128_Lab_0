import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class RouteMiniMap extends StatefulWidget {
  const RouteMiniMap({
    super.key,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    this.routePath = const [],
    this.routeColor = '#1261A6',
  });

  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final List<List<double>> routePath;
  final String routeColor;

  @override
  State<RouteMiniMap> createState() => _RouteMiniMapState();
}

class _RouteMiniMapState extends State<RouteMiniMap> {
  static const _sourceId = 'route-mini-map-source';
  static const _lineLayerId = 'route-mini-map-line';
  static const _stopLayerId = 'route-mini-map-stops';

  MapboxMap? _map;
  bool _styleLoaded = false;

  static List<List<double>> _coordinatesFor(RouteMiniMap map) {
    final path = map.routePath.where((point) => point.length >= 2).toList();
    if (path.length >= 2) return path;
    return [
      [map.startLng, map.startLat],
      [map.endLng, map.endLat],
    ];
  }

  static bool _sameCoordinates(
    List<List<double>> first,
    List<List<double>> second,
  ) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index].length < 2 ||
          second[index].length < 2 ||
          first[index][0] != second[index][0] ||
          first[index][1] != second[index][1]) {
        return false;
      }
    }
    return true;
  }

  String _routeGeoJson(List<List<double>> coordinates) => jsonEncode({
    'type': 'FeatureCollection',
    'features': [
      {
        'type': 'Feature',
        'properties': {'color': widget.routeColor},
        'geometry': {'type': 'LineString', 'coordinates': coordinates},
      },
      {
        'type': 'Feature',
        'properties': {'color': '#1261A6'},
        'geometry': {'type': 'Point', 'coordinates': coordinates.first},
      },
      {
        'type': 'Feature',
        'properties': {'color': '#D32F2F'},
        'geometry': {'type': 'Point', 'coordinates': coordinates.last},
      },
    ],
  });

  Future<void> _drawRoute() async {
    final map = _map;
    if (map == null || !_styleLoaded || !mounted) return;

    final style = map.style;
    if (await style.styleLayerExists(_stopLayerId)) {
      await style.removeStyleLayer(_stopLayerId);
    }
    if (await style.styleLayerExists(_lineLayerId)) {
      await style.removeStyleLayer(_lineLayerId);
    }
    if (await style.styleSourceExists(_sourceId)) {
      await style.removeStyleSource(_sourceId);
    }

    final coordinates = _coordinatesFor(widget);
    await style.addSource(
      GeoJsonSource(id: _sourceId, data: _routeGeoJson(coordinates)),
    );
    await style.addLayer(
      LineLayer(
        id: _lineLayerId,
        sourceId: _sourceId,
        lineColorExpression: ['get', 'color'],
        lineWidth: 3,
        lineCap: LineCap.ROUND,
        lineJoin: LineJoin.ROUND,
      ),
    );
    await style.addLayer(
      CircleLayer(
        id: _stopLayerId,
        sourceId: _sourceId,
        circleRadius: 5,
        circleColorExpression: ['get', 'color'],
        circleStrokeColor: 0xFFFFFFFF,
        circleStrokeWidth: 2,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant RouteMiniMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameCoordinates(
          _coordinatesFor(oldWidget),
          _coordinatesFor(widget),
        ) ||
        oldWidget.routeColor != widget.routeColor) {
      unawaited(_drawRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final coordinates = _coordinatesFor(widget);
    final points = [
      for (final coordinate in coordinates)
        Point(coordinates: Position(coordinate[0], coordinate[1])),
    ];

    return SizedBox(
      height: 160,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: MapWidget(
          styleUri: MapboxStyles.MAPBOX_STREETS,
          textureView: true,
          onMapCreated: (map) async {
            _map = map;
            final camera = await map.cameraForCoordinates(
              points,
              MbxEdgeInsets(top: 30, left: 30, bottom: 30, right: 30),
              null,
              null,
            );
            await map.setCamera(camera);
          },
          onStyleLoadedListener: (_) {
            _styleLoaded = true;
            unawaited(_drawRoute());
          },
        ),
      ),
    );
  }
}
