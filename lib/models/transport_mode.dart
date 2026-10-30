// Collection: transport_modes 
class TransportMode {
  const TransportMode({required this.id, required this.name});

  final String id; 
  final String name;

  factory TransportMode.fromMap(String id, Map<String, dynamic> map) {
    return TransportMode(
      id: id,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() => {'name': name};
}
