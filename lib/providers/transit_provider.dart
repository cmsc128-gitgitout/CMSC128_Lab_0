import 'package:flutter/foundation.dart';

import '../models/boarding_point.dart';
import '../models/transit_route.dart';
import '../models/transport_mode.dart';
import '../services/transit_service.dart';

// Holds the loaded transit data and notifies the UI when it changes.
class TransitProvider extends ChangeNotifier {
  TransitProvider(this._service);

  final TransitService _service;

  bool _isLoading = false;
  String? _error;
  Map<String, TransportMode> _modes = {};
  Map<String, BoardingPoint> _points = {};
  List<TransitRoute> _routes = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TransitRoute> get routes => _routes;

  // Boarding points flagged as terminals, sorted by name.
  List<BoardingPoint> get terminals =>
      (_points.values.where((p) => p.isTerminal).toList())
        ..sort((a, b) => a.name.compareTo(b.name));

  // Loads everything from Firestore. Also used for "Try again".
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final (modes, points, routes) = await (
        _service.fetchTransportModes(),
        _service.fetchBoardingPoints(),
        _service.fetchRoutes(),
      ).wait;

      _modes = {for (final m in modes) m.id: m};
      _points = {for (final p in points) p.id: p};
      _routes = routes..sort((a, b) => a.routeNo.compareTo(b.routeNo));
    } catch (e) {
      debugPrint('TransitProvider.load failed: $e');
      _error = 'Could not load data. Check your connection and try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String modeName(String modeId) => _modes[modeId]?.name ?? '';

  String stopName(String stopId) => _points[stopId]?.name ?? '';

  // "First stop → last stop" for a route, or '' if it has no stops.
  String routeEndpoints(TransitRoute route) {
    if (route.stopIds.isEmpty) return '';
    final first = stopName(route.stopIds.first);
    final last = stopName(route.stopIds.last);
    return '$first → $last';
  }

  // Names of the transport modes whose routes pass through [stopId].
  List<String> modeNamesServing(String stopId) {
    final modeIds = _routes
        .where((r) => r.stopIds.contains(stopId))
        .map((r) => r.transportModeId)
        .toSet();
    return modeIds.map(modeName).where((n) => n.isNotEmpty).toList();
  }
}
