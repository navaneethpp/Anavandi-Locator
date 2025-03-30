import 'package:flutter/material.dart';
import 'package:anavandi_locator/data/models/place.dart';

class PlaceSuggestionList extends StatelessWidget {
  final List<Place> suggestions;
  final Function(Place) onSelected;

  const PlaceSuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.white, // Or your preferred background color
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final place = suggestions[index];
          return ListTile(
            title: Text(place.placeName),
            onTap: () => onSelected(place),
          );
        },
      ),
    );
  }
}
