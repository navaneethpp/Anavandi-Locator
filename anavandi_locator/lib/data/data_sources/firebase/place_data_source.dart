import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anavandi_locator/data/models/place.dart';

class PlaceDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Place>> getPlacesByName(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final lowercaseQuery = query.toLowerCase();
    final snapshot = await _firestore.collection('placeData').get();

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
    final snapshot = await _firestore.collection('placeData').get();
    return snapshot.docs.map((doc) => Place.fromJson(doc.data())).toList();
  }
}
