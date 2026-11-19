import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static const _token = String.fromEnvironment('ACCESS_TOKEN');

  // Returns a place name for the coordinates, or null if the lookup fails.
  static Future<String?> reverse(double lat, double lng) async {
    final uri = Uri.https('api.mapbox.com', '/search/geocode/v6/reverse', {
      'longitude': '$lng',
      'latitude': '$lat',
      'access_token': _token,
    });
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      final features = jsonDecode(res.body)['features'] as List;
      if (features.isEmpty) return null;
      final props = features.first['properties'] as Map<String, dynamic>;
      return (props['name'] ?? props['full_address']) as String?;
    } catch (_) {
      return null; // offline, timeout, bad response
    }
  }
}