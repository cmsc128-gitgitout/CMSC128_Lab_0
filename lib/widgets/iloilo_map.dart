import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../models/transit_route.dart';

/// A line to draw on the map. [coordinates] are [lng, lat].
class MapLine {
  const MapLine({required this.coordinates, required this.colorHex});
  final List<List<double>> coordinates;
  final String colorHex; // e.g. '#1261A6'
}

/// A dot on the map.
class MapMarker {
  const MapMarker({
    required this.lat,
    required this.lng,
    required this.colorHex,
  });
  final double lat;
  final double lng;
  final String colorHex;
}

class IloiloMap extends StatefulWidget {
  const IloiloMap({
    super.key,
    this.routes = const [],
    this.showLocationPuck = false,
  });

  final List<TransitRoute> routes;
  final bool showLocationPuck;
    this.lines = const [],
    this.highlight,
    this.markers = const [],
    this.cameraPadding = EdgeInsets.zero,
    this.zoom = 12,
    this.onMapCreated,
  });

  final List<TransitRoute> routes; // old behaviour (Network screen)
  final List<MapLine> lines; // other options, drawn underneath
  final MapLine? highlight; // selected option, drawn on top
  final List<MapMarker> markers; // start / destination dots
  final EdgeInsets cameraPadding; // keeps the fit clear of the header / sheet
  final double zoom;
  final void Function(MapboxMap map)? onMapCreated;

  @override
  IloiloMapState createState() => IloiloMapState();
}

class IloiloMapState extends State<IloiloMap> {
  MapboxMap? _map;
  bool _mapReady = false;
  bool _styleLoaded = false;

  // Draws never overlap: each one is chained onto this.
  Future<void> _queue = Future.value();

  // Source / layer ids, one pair per thing we draw.
  static const _routesSource = 'routes-source';
  static const _routesLayer = 'routes-line';
  static const _linesSource = 'other-lines-source';
  static const _linesLayer = 'other-lines-layer';
  static const _highlightSource = 'highlight-source';
  static const _highlightLayer = 'highlight-layer';
  static const _markersSource = 'markers-source';
  static const _markersLayer = 'markers-layer';

  static const _allLayers = [
    _routesLayer,
    _linesLayer,
    _highlightLayer,
    _markersLayer,
  ];
  static const _allSources = [
    _routesSource,
    _linesSource,
    _highlightSource,
    _markersSource,
  ];

  static const List<String> _routeColors = [
    '#800080',
    '#1565C0',
    '#FFFF00',
    '#00FF00',
  ];

  Future<bool> centerOnLocation({
    required double latitude,
    required double longitude,
  }) async {
    final map = _map;
    if (map == null || !_mapReady) return false;

    await map.location.updateSettings(
      LocationComponentSettings(enabled: true, showAccuracyRing: true),
    );
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
  // ---------------------------------------------------------------------
  // Scheduling
  // ---------------------------------------------------------------------

  void _scheduleDraw({required bool fit}) {
    _queue = _queue.then((_) => _drawAll(fit: fit));
  }

  @override
  void didUpdateWidget(covariant IloiloMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `!=` on lists/objects is identity. The results screen must keep
    // these stable between builds (see step 6).
    final changed = oldWidget.routes != widget.routes ||
        oldWidget.lines != widget.lines ||
        oldWidget.highlight != widget.highlight ||
        oldWidget.markers != widget.markers;
    if (changed) {
      _scheduleDraw(
        fit: oldWidget.highlight != widget.highlight ||
            oldWidget.lines != widget.lines,
      );
    }
    if (oldWidget.showLocationPuck != widget.showLocationPuck) {
      _updateLocationPuck();
    }
  }

  Future<void> _updateLocationPuck() async {
    final map = _map;
    if (map == null || !_mapReady) return;

    await map.location.updateSettings(
      LocationComponentSettings(
        enabled: widget.showLocationPuck,
        showAccuracyRing: widget.showLocationPuck,
      ),
    );
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
  // ---------------------------------------------------------------------
  // GeoJSON builders
  // ---------------------------------------------------------------------

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

  String _linesGeoJson(List<MapLine> lines) => jsonEncode({
        'type': 'FeatureCollection',
        'features': [
          for (final l in lines)
            if (l.coordinates.length >= 2)
              {
                'type': 'Feature',
                'properties': {'color': l.colorHex},
                'geometry': {
                  'type': 'LineString',
                  'coordinates': l.coordinates,
                },
              },
        ],
      });

  String _markersGeoJson() => jsonEncode({
        'type': 'FeatureCollection',
        'features': [
          for (final m in widget.markers)
            {
              'type': 'Feature',
              'properties': {'color': m.colorHex},
              'geometry': {
                'type': 'Point',
                'coordinates': [m.lng, m.lat],
              },
            },
        ],
      });

  // ---------------------------------------------------------------------
  // Drawing
  // ---------------------------------------------------------------------

  Future<void> _drawAll({required bool fit}) async {
    final map = _map;
    if (map == null || !_styleLoaded || !mounted) return;

    // Read the screen size before any await.
    final screen = MediaQuery.of(context).size;

    try {
      final style = map.style;

      // 1. Remove everything we own (layers first, then sources).
      for (final id in _allLayers) {
        if (await style.styleLayerExists(id)) {
          await style.removeStyleLayer(id);
        }
      }
      for (final id in _allSources) {
        if (await style.styleSourceExists(id)) {
          await style.removeStyleSource(id);
        }
      }

      // 2. Old routes (Network screen).
      if (widget.routes.isNotEmpty) {
        await style.addSource(
          GeoJsonSource(id: _routesSource, data: _routesGeoJson()),
        );
        await style.addLayer(
          LineLayer(
            id: _routesLayer,
            sourceId: _routesSource,
            lineColorExpression: ['get', 'color'],
            lineWidth: 4.0,
            lineCap: LineCap.ROUND,
            lineJoin: LineJoin.ROUND,
          ),
        );
      }

      // 3. Other options (grey, underneath).
      if (widget.lines.isNotEmpty) {
        await style.addSource(
          GeoJsonSource(id: _linesSource, data: _linesGeoJson(widget.lines)),
        );
        await style.addLayer(
          LineLayer(
            id: _linesLayer,
            sourceId: _linesSource,
            lineColorExpression: ['get', 'color'],
            lineWidth: 4.0,
            lineCap: LineCap.ROUND,
            lineJoin: LineJoin.ROUND,
          ),
        );
      }

      // 4. Selected option (on top of the grey ones).
      final highlight = widget.highlight;
      if (highlight != null && highlight.coordinates.length >= 2) {
        await style.addSource(
          GeoJsonSource(
            id: _highlightSource,
            data: _linesGeoJson([highlight]),
          ),
        );
        await style.addLayer(
          LineLayer(
            id: _highlightLayer,
            sourceId: _highlightSource,
            lineColorExpression: ['get', 'color'],
            lineWidth: 6.0,
            lineCap: LineCap.ROUND,
            lineJoin: LineJoin.ROUND,
          ),
        );
      }

      // 5. Start / destination dots (topmost).
      if (widget.markers.isNotEmpty) {
        await style.addSource(
          GeoJsonSource(id: _markersSource, data: _markersGeoJson()),
        );
        await style.addLayer(
          CircleLayer(
            id: _markersLayer,
            sourceId: _markersSource,
            circleRadius: 8.0,
            circleColorExpression: ['get', 'color'],
            circleStrokeColor: 0xFFFFFFFF,
            circleStrokeWidth: 3.0,
          ),
        );
      }

      // 6. Camera: fit the highlight if there is one, otherwise all lines.
      if (fit && mounted) {
        final coords = highlight?.coordinates ??
            [for (final l in widget.lines) ...l.coordinates];
        if (coords.isNotEmpty) await _fitTo(coords, screen);
      }
    } catch (e) {
      // Swallow so one failed draw does not break the queue.
      debugPrint('drawing unsuccessful $e');
    }
  }

  Future<void> _fitTo(List<List<double>> coords, Size screen) async {
    final map = _map;
    if (map == null || coords.isEmpty) return;

    var minLng = coords.first[0], maxLng = coords.first[0];
    var minLat = coords.first[1], maxLat = coords.first[1];
    for (final c in coords) {
      minLng = min(minLng, c[0]);
      maxLng = max(maxLng, c[0]);
      minLat = min(minLat, c[1]);
      maxLat = max(maxLat, c[1]);
    }

    final pad = widget.cameraPadding;
    final w = max(1.0, screen.width - pad.left - pad.right);
    final h = max(1.0, screen.height - pad.top - pad.bottom);

    // Small minimum so a one-point line does not divide by zero.
    final lngSpan = max(maxLng - minLng, 0.0005);
    final latSpan = max(maxLat - minLat, 0.0005);
    final latMid = (minLat + maxLat) / 2;

    // Web-mercator: the world is 512 px wide at zoom 0.
    final zLng = log(w * 360 / (512 * lngSpan)) / ln2;
    final zLat =
        log(h * 360 * cos(latMid * pi / 180) / (512 * latSpan)) / ln2;
    final zoom = (min(zLng, zLat) - 0.2).clamp(11.0, 17.0);

    await map.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position((minLng + maxLng) / 2, latMid),
        ),
        zoom: zoom,
        padding: MbxEdgeInsets(
          top: pad.top,
          left: pad.left,
          bottom: pad.bottom,
          right: pad.right,
        ),
      ),
      MapAnimationOptions(duration: 700),
    );
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: MapboxStyles.MAPBOX_STREETS,
      viewport: CameraViewportState(
        center: Point(coordinates: Position(122.5621, 10.7202)), // lng, lat
        zoom: widget.zoom,
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
        await _updateLocationPuck();
        widget.onMapCreated?.call(map);
      },
      // Draw only after the style is ready.
      onStyleLoadedListener: (_) {
        _styleLoaded = true;
        _scheduleDraw(fit: widget.highlight != null || widget.lines.isNotEmpty);
      },
    );
  }
}
