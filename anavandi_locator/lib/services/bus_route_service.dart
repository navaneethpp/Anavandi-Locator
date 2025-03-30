import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anavandi_locator/data/models/bus_model.dart';

class BusRouteService {
  static Future<Bus?> fetchBusLocation(String busRegistrationNumber) async {
    try {
      final busDataSnapshot =
          await FirebaseFirestore.instance
              .collection('busData')
              .where(
                'busRegistrationNumber',
                isEqualTo: busRegistrationNumber.trim(),
              )
              .limit(1)
              .get();

      if (busDataSnapshot.docs.isNotEmpty) {
        return Bus.fromFirestore(busDataSnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error fetching bus location: $e');
      return null;
    }
  }

  static Future<String?> fetchTripIdFromAssignData(
    String busRegistrationNumber,
  ) async {
    try {
      final assignDataSnapshot =
          await FirebaseFirestore.instance
              .collection('assignData')
              .where(
                'busRegistrationNumber',
                isEqualTo: busRegistrationNumber.trim(),
              )
              .limit(1)
              .get();

      if (assignDataSnapshot.docs.isNotEmpty) {
        return assignDataSnapshot.docs.first.data()['tripId'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching tripId from assignData: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchBusStopsData(
    String tripId,
  ) async {
    try {
      final assignDataSnapshot =
          await FirebaseFirestore.instance
              .collection('assignData')
              .where('tripId', isEqualTo: tripId.trim())
              .limit(1)
              .get();

      if (assignDataSnapshot.docs.isNotEmpty) {
        final assignData = assignDataSnapshot.docs.first.data();
        if (assignData['busStops'] is List) {
          return (assignData['busStops'] as List).cast<Map<String, dynamic>>();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching bus stops data: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchRouteStopsByRouteId(
    String routeId,
  ) async {
    try {
      final routeDataSnapshot =
          await FirebaseFirestore.instance
              .collection('routeData')
              .where('routeId', isEqualTo: routeId.trim())
              .limit(1)
              .get();

      if (routeDataSnapshot.docs.isNotEmpty) {
        final routeData = routeDataSnapshot.docs.first.data();
        if (routeData['stops'] is List) {
          return (routeData['stops'] as List).cast<Map<String, dynamic>>();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching route data: $e');
      return null;
    }
  }
}
