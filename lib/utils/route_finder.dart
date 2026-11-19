import 'dart:math';

import '../models/boarding_point.dart';
import '../models/transit_route.dart';
import '../models/trip_option.dart';

// PLACEHOLDER until the backend defines a fare rule.
double fareForRide(TransitRoute r) => r.minFare;

// PLACEHOLDER until the backend defines a fare rule.
double studentFareFor(double regular) => regular;

// ---------------------------------------------------------------------------
// Distance helper
// ---------------------------------------------------------------------------

/// Planar distance in degrees between two [lng, lat] points.
double _dist(List<double> a, List<double> b) {
  final dx = a[0] - b[0];
  final dy = a[1] - b[1];
  return sqrt(dx * dx + dy * dy);
}

// ---------------------------------------------------------------------------
// Per-route preparation (built once per findTrips call)
// ---------------------------------------------------------------------------

class _PreparedRoute {
  _PreparedRoute({
    required this.route,
    required this.stops,
    required this.points,
    required this.cumLen,
    required this.stopIndex,
  });

  final TransitRoute route;
  final List<BoardingPoint> stops; // same order as route.stopIds
  final List<List<double>> points; // [lng, lat]: route.path or the stops
  final List<double> cumLen; // cumulative length (degrees) at each point
  final List<int> stopIndex; // for each stop, its index into [points]

  double get totalLen => cumLen.last;

  /// Returns null if the route can't be used.
  static _PreparedRoute? build(
    TransitRoute route,
    BoardingPoint? Function(String) stopById,
  ) {
    if (!route.isActive) return null;
    if (route.stopIds.length < 2) return null;

    final stops = <BoardingPoint>[];
    for (final id in route.stopIds) {
      final s = stopById(id);
      if (s == null) return null; // missing stop: skip the whole route
      stops.add(s);
    }

    final hasPath = route.path.length >= 2;
    final List<List<double>> points = hasPath
        ? route.path
        : [
            for (final s in stops) [s.lng, s.lat],
          ];

    final cumLen = <double>[0];
    for (var i = 1; i < points.length; i++) {
      cumLen.add(cumLen.last + _dist(points[i - 1], points[i]));
    }

    final stopIndex = <int>[];
    if (!hasPath) {
      for (var k = 0; k < stops.length; k++) {
        stopIndex.add(k);
      }
    } else {
      var from = 0; // always move forward, never restart from 0
      for (final s in stops) {
        final target = [s.lng, s.lat];
        var best = from;
        var bestDist = double.infinity;
        for (var i = from; i < points.length; i++) {
          final d = _dist(points[i], target);
          if (d < bestDist) {
            bestDist = d;
            best = i;
          }
        }
        stopIndex.add(best);
        from = best;
      }
    }

    return _PreparedRoute(
      route: route,
      stops: stops,
      points: points,
      cumLen: cumLen,
      stopIndex: stopIndex,
    );
  }
}

/// One ride: board at stop index [start], get off at stop index [end].
class _Ride {
  const _Ride(this.prepared, this.start, this.end);
  final _PreparedRoute prepared;
  final int start;
  final int end;
}

// ---------------------------------------------------------------------------
// Build one TripOption from a list of rides
// ---------------------------------------------------------------------------

TripOption _buildOption(
  List<_Ride> rides,
  String Function(String modeId) modeName,
) {
  final legs = <TripLeg>[];

  for (final ride in rides) {
    final pr = ride.prepared;
    final r = pr.route;
    final from = pr.stops[ride.start];
    final to = pr.stops[ride.end];

    final startPt = pr.stopIndex[ride.start];
    final endPt = pr.stopIndex[ride.end];

    final total = pr.totalLen;
    var fraction =
        total > 0 ? (pr.cumLen[endPt] - pr.cumLen[startPt]) / total : 0.0;
    if (fraction <= 0) {
      fraction = (ride.end - ride.start) / (pr.stops.length - 1);
    }

    // Real km comes only from the data. Missing length_km shows as 0.
    final declaredKm = r.lengthKm; // local copy so Dart can null-promote
    final km = declaredKm != null ? declaredKm * fraction : 0.0;

    final minutes = max(1, (r.duration * fraction).round());

    final List<List<double>> legPath = endPt > startPt
        ? pr.points.sublist(startPt, endPt + 1)
        : [
            [from.lng, from.lat],
            [to.lng, to.lat],
          ];

    legs.add(TripLeg(
      routeNo: r.routeNo,
      routeName: r.name,
      modeName: modeName(r.transportModeId),
      from: from,
      to: to,
      minutes: minutes,
      distanceKm: km,
      fare: fareForRide(r),
      path: legPath,
    ));
  }

  final duration = legs.fold<int>(0, (sum, l) => sum + l.minutes);
  final fare = legs.fold<double>(0, (sum, l) => sum + l.fare);

  return TripOption(
    legs: legs,
    durationMinutes: duration,
    fare: fare,
    studentFare: studentFareFor(fare),
  );
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

List<TripOption> findTrips({
  required BoardingPoint origin,
  required BoardingPoint destination,
  required List<TransitRoute> routes,
  required BoardingPoint? Function(String stopId) stopById,
  required String Function(String modeId) modeName,
}) {
  if (origin.id == destination.id) return [];

  final prepared = <_PreparedRoute>[];
  for (final r in routes) {
    final p = _PreparedRoute.build(r, stopById);
    if (p != null) prepared.add(p);
  }

  // One option per unique chain of routes; keep the fastest.
  final results = <String, TripOption>{};

  void search(String currentStopId, List<_Ride> rides, Set<String> visited) {
    for (final pr in prepared) {
      // Never ride the same route number twice in one trip.
      if (rides.any((r) => r.prepared.route.routeNo == pr.route.routeNo)) {
        continue;
      }

      final i = pr.route.stopIds.indexOf(currentStopId);
      if (i < 0) continue;

      for (var j = i + 1; j < pr.route.stopIds.length; j++) {
        final stopId = pr.route.stopIds[j];
        if (visited.contains(stopId)) continue;

        final ride = _Ride(pr, i, j);

        if (stopId == destination.id) {
          final chain = [...rides, ride];
          final option = _buildOption(chain, modeName);
          final key = chain.map((r) => r.prepared.route.id).join('>');
          final existing = results[key];
          if (existing == null ||
              option.durationMinutes < existing.durationMinutes) {
            results[key] = option;
          }
          break; // riding past the destination is pointless
        }

        search(stopId, [...rides, ride], {...visited, stopId});
      }
    }
  }

  search(origin.id, const [], {origin.id});

  final list = results.values.toList()
    ..sort((a, b) {
      final byTime = a.durationMinutes.compareTo(b.durationMinutes);
      return byTime != 0 ? byTime : a.transfers.compareTo(b.transfers);
    });
  return list; // no cap: everything the data allows
}