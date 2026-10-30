import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/boarding_point.dart';
import '../models/transit_route.dart';
import '../models/transport_mode.dart';

// Reads transit data from Firestore and converts it into models.
// No state lives here; see TransitProvider.
class TransitService {
  TransitService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<List<TransportMode>> fetchTransportModes() async {
    final snap = await _db.collection('transport_modes').get();
    return snap.docs.map((d) => TransportMode.fromMap(d.id, d.data())).toList();
  }

  Future<List<BoardingPoint>> fetchBoardingPoints() async {
    final snap = await _db.collection('boarding_points').get();
    return snap.docs.map((d) => BoardingPoint.fromMap(d.id, d.data())).toList();
  }

  // Only active routes are returned.
  Future<List<TransitRoute>> fetchRoutes() async {
    final snap = await _db
        .collection('routes')
        .where('is_active', isEqualTo: true)
        .get();
    return snap.docs.map((d) => TransitRoute.fromMap(d.id, d.data())).toList();
  }
}