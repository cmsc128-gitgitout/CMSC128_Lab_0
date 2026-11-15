import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // for local storage

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

  String _searchQuery = '';
  List<TransitRoute> get routes => _routes;
  String get searchQuery => _searchQuery;

  
  static const _recentKey = 'recent_searches'; //use for reading/writing list on device 
  List<String> _recentSearches = []; //holds list
  List<String> get recentSearches => _recentSearches; 

  List<TransitRoute> get goingRoutes => _routes.where((r) => r.direction == 'going').toList();

  List<TransitRoute> get returningRoutes => _routes.where((r) => r.direction == 'returning').toList();


  // Boarding points flagged as terminals, sorted by name.
  List<BoardingPoint> get terminals =>
      (_points.values.where((p) => p.isTerminal).toList())
        ..sort((a, b) => a.name.compareTo(b.name));



  void setSearchQuery(String query) {
      if (_searchQuery == query) return;
      _searchQuery = query;
      notifyListeners();
    }


  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }

  // save when user submits search
  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return; //not inckyde if empty

    _recentSearches.removeWhere((s) => s.toLowerCase() == trimmed.toLowerCase()); //handle duplicatess
    _recentSearches.insert(0, trimmed); 
    if (_recentSearches.length > 7) { //only show till 7 676767
      _recentSearches = _recentSearches.sublist(0, 7);
    }

    notifyListeners();
    //opnes connnection to device then overwrtie recent searches
    final prefs = await SharedPreferences.getInstance();  
    await prefs.setStringList(_recentKey, _recentSearches);
  }

  //clear all
  Future<void> clearRecentSearches() async {
  _recentSearches.clear();
  notifyListeners();
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_recentKey);
  }
  Future<void> removeRecentSearch(String query) async {
    _recentSearches.remove(query);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, _recentSearches);
  }



// filter by route number, route name, transport mode, or stops 
  List<TransitRoute> get filteredRoutes {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _routes;

    final keywords = q.split(RegExp(r'\s+'));
    return _routes.where((route) {
      final no = route.routeNo.toLowerCase();
      final name = route.name.toLowerCase();
      final mode = modeName(route.transportModeId).toLowerCase();
      final stops = route.stopIds.map((id) =>stopName(id).toLowerCase()).toList();

      return keywords.every((word) =>
          no.contains(word) ||
          name.contains(word) ||
          mode.contains(word) ||
          stops.any((s) => s.contains(word)));
    }).toList();
  }

  // Stops whose name contains every word in [query]
  // Pure lookup only and does not touch the shared search state, so Plan trip and Network search can use it at the same time.
  List<BoardingPoint> searchStops(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final keywords = q.split(RegExp(r'\s+'));
    return (_points.values.where((p) {
      final name = p.name.toLowerCase();
      return keywords.every((word) => name.contains(word));
    }).toList())
      ..sort((a, b) => a.name.compareTo(b.name));
  }


  // filter by stops
  List<BoardingPoint> get filteredStops => searchStops(_searchQuery);

  // the stop with exactly this name (case-insensitive) or null. Turns a saved recent search back into a stop.
  BoardingPoint? stopByName(String name) {
    final n = name.trim().toLowerCase();
    for (final p in _points.values) {
      if (p.name.toLowerCase() == n) return p;
    }
    return null;
  }


  // Loads everything from Firestore. Also used for "Try again".
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      //load recent searches
      final prefs = await SharedPreferences.getInstance();
      _recentSearches = prefs.getStringList(_recentKey) ?? [];

      final (modes, points, going, returning) = await (
        _service.fetchTransportModes(),
        _service.fetchBoardingPoints(),
        _service.fetchGoingRoutes(),
        _service.fetchReturningRoutes(),
      ).wait;

      _modes = {for (final m in modes) m.id: m};
      _points = {for (final p in points) p.id: p};
      _routes = [...going, ...returning]
        ..sort((a, b) => a.routeNo.compareTo(b.routeNo));
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

  BoardingPoint? stopById(String stopId) => _points[stopId];

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