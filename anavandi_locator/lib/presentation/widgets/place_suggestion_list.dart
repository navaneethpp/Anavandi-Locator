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

    // Estimate the height of a single suggestion item (ListTile)
    const double suggestionItemHeight = 48.0; // Adjust this value if needed

    // Calculate the ideal height for the suggestion list
    final double idealHeight = suggestions.length * suggestionItemHeight;

    // Set a maximum height to prevent the list from taking over the screen
    final double maxHeight = MediaQuery.of(context).size.height * 0.4;

    // Determine the actual height to use, which is the smaller of the ideal and maximum height
    final double actualHeight =
        idealHeight < maxHeight ? idealHeight : maxHeight;

    return Container(
      color: Colors.white, // Or your preferred background color
      child: SizedBox(
        height: actualHeight, // Use the calculated actual height
        child: ListView.builder(
          padding: EdgeInsets.zero, // Explicitly set padding to zero
          shrinkWrap: true, // Keep shrinkWrap true for dynamic height
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
      ),
    );
  }
}
