import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:anavandi_locator/utils/utils.dart';

class OSRMService {
  static Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    try {
      final startLon = start.longitude.toString();
      final startLat = start.latitude.toString();
      final endLon = end.longitude.toString();
      final endLat = end.latitude.toString();

      if (!isValidCoordinate(start.latitude, start.longitude) ||
          !isValidCoordinate(end.latitude, end.longitude)) {
        print(
          'Invalid coordinates detected for OSRM: Start($startLat,$startLon), End($endLat,$endLon)',
        );
        return [];
      }

      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '$startLon,$startLat;$endLon,$endLat'
          '?overview=full&geometries=polyline';

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('OSRM request timed out');
              return http.Response('{"code":"Timeout"}', 408);
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          return _decodePolyline(geometry);
        } else {
          print('OSRM response missing routes: ${response.body}');
        }
      } else {
        print('OSRM request failed: ${response.statusCode} - ${response.body}');
      }
      return [];
    } catch (e) {
      print('Error fetching route from OSRM: $e');
      return [];
    }
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    try {
      while (index < len) {
        int b, shift = 0, result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        double latitude = lat / 1e5;
        double longitude = lng / 1e5;
        if (isValidCoordinate(latitude, longitude)) {
          points.add(LatLng(latitude, longitude));
        }
      }
    } catch (e) {
      print('Error decoding polyline: $e');
    }
    return points;
  }
}
