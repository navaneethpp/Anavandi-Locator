import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anavandi_locator/data/models/place.dart';
import 'package:geolocator/geolocator.dart'; // For distance calculation

class PlaceDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _placesCollection = 'placeData';

  Future<List<Place>> getPlacesByName(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final lowercaseQuery = query.toLowerCase();
    final snapshot = await _firestore.collection(_placesCollection).get();

    print('Fetched ${snapshot.docs.length} documents from placeData');

    List<Place> allPlaces =
        snapshot.docs.map((doc) {
          final place = Place.fromJson(doc.data());
          print('Fetched placeName: ${place.placeName}');
          return place;
        }).toList();

    List<Place> filteredPlaces =
        allPlaces
            .where(
              (place) =>
                  place.placeName.toLowerCase().startsWith(lowercaseQuery),
            )
            .toList();

    print('Number of places after filtering: ${filteredPlaces.length}');

    return filteredPlaces;
  }

  Future<List<Place>> getAllPlaces() async {
    final snapshot = await _firestore.collection(_placesCollection).get();
    return snapshot.docs.map((doc) => Place.fromJson(doc.data())).toList();
  }

  Future<Place?> getNearestPlace({
    required double latitude,
    required double longitude,
  }) async {
    final snapshot = await _firestore.collection(_placesCollection).get();
    List<Place> allPlaces =
        snapshot.docs.map((doc) {
          return Place.fromJson(doc.data());
        }).toList();

    if (allPlaces.isEmpty) {
      return null;
    }

    double minDistance = double.infinity;
    Place? nearestPlace;

    for (final place in allPlaces) {
      // Assuming your Place model now has latitude and longitude properties
      if (place.latitude != null && place.longitude != null) {
        double distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          place.latitude!,
          place.longitude!,
        );
        if (distance < minDistance) {
          minDistance = distance;
          nearestPlace = place;
        }
      }
    }

    return nearestPlace;
  }
}
