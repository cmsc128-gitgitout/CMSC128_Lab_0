// import 'package:flutter/foundation.dart'; 
import '../utils/firestore_datetime.dart';

// Collection: routes 
//
// Named TransitRoute to avoid clashing with Flutter's built-in `Route` class.
// The drawn path lives in the separate `route_paths` collection (RoutePath).
class TransitRoute {
  const TransitRoute({
    required this.id,
    required this.routeNo,
    required this.name,
    required this.direction,
    required this.transportModeId,
    required this.stopIds,

    required this.duration,
    required this.minFare,

    this.path = const [], 
    this.lengthKm,
    this.lastVerified,
    this.isActive = true,


  });

  final String id; // document id
  final List<List<double>> path; //[lng, lat] format same w mapbox
  final String routeNo; // official LTFRB route number
  final String name;
  final String direction; // going or returning
  final String transportModeId; // id of a transport_modes doc (field: tmode_id)
  final List<String> stopIds; // boarding_points ids, in order
  final double? lengthKm;
  final DateTime? lastVerified;
  final bool isActive;

  final int duration;
  final double minFare;


factory TransitRoute.fromMap(String id, Map<String, dynamic> map) {
    // convert firestore arr containing  maps to [ array pairs for mapbox 
    final pathForMapbox = map['path'] as List? ?? [];
    //loop through
    final List<List<double>> parsedPath = [];
    for (final item in pathForMapbox){
      //vhrvk if same type 
      // if (item is! Map) {
      //   debugPrint('TransitRoute $id: skipped poinr: $item');
      //   continue;
      // }
      final point = item as Map<String, dynamic>;
      final lngRaw = point['lng'];
      final latRaw = point['lat'];
      // if (lngRaw is! num||latRaw is! num) {
      //   debugPrint('TransitRoute $id: skipp: $item');
      //   continue;
      // }
      final double lng = lngRaw.toDouble();
      final double lat = latRaw.toDouble();
      parsedPath.add([lng, lat]);
    }

    return TransitRoute(
      id: id,
      routeNo: map['route_no'] as String,
      name: map['name'] as String,
      direction: map['direction'] as String,
      transportModeId: map['tmode_id'] as String,
      stopIds: List<String>.from(map['stop_ids'] as List),
      lengthKm: (map['length_km'] as num?)?.toDouble(),
      lastVerified: parseDateTime(map['last_verified']),
      isActive: map['is_active'] as bool? ?? true,
      path: parsedPath,

      duration: (map['duration'] as num?)?.toInt() ?? 0,
      minFare: (map['min_fare'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {
        'route_no': routeNo,
        'name': name,
        'direction': direction,
        'tmode_id': transportModeId,
        'stop_ids': stopIds,
        if (lengthKm != null) 'length_km': lengthKm,
        if (lastVerified != null) 'last_verified': lastVerified,
        'is_active': isActive,
      };
}