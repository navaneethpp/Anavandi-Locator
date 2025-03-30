import 'package:anavandi_locator/data/models/place.dart';
import 'package:anavandi_locator/data/data_sources/firebase/place_data_source.dart';

class PlaceRepository {
  final PlaceDataSource _placeDataSource = PlaceDataSource();

  Future<List<Place>> getPlacesByName(String query) async {
    return _placeDataSource.getPlacesByName(query);
  }

  Future<List<Place>> getAllPlaces() async {
    return _placeDataSource.getAllPlaces();
  }
}
