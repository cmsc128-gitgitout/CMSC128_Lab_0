// Collection: boarding_points 
class BoardingPoint {
  const BoardingPoint({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.isTerminal = false,
  });

  final String id; // document id
  final String name;
  final double lat;
  final double lng;
  final bool isTerminal;

  factory BoardingPoint.fromMap(String id, Map<String, dynamic> map) {
    return BoardingPoint(
      id: id,
      name: map['name'] as String,
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      isTerminal: map['is_terminal'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'lat': lat,
        'lng': lng,
        'is_terminal': isTerminal,
      };
}
