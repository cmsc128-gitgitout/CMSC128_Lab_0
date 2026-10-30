// A coordinate pair, stored in Firestore as a map: {lat, lng}.
class LatLngPoint {
  const LatLngPoint({required this.lat, required this.lng});

  final double lat;
  final double lng;

  factory LatLngPoint.fromMap(Map<String, dynamic> map) {
    return LatLngPoint(
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {'lat': lat, 'lng': lng};
}
