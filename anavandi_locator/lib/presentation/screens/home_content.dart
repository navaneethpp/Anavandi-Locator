import 'package:flutter/material.dart';
import 'package:anavandi_locator/common/widgets/custom_text_field.dart';
import 'package:anavandi_locator/common/widgets/submit_button.dart';
import 'package:anavandi_locator/data/models/place.dart';
import 'package:anavandi_locator/data/repositories/place_repository.dart';
import 'package:anavandi_locator/presentation/widgets/place_suggestion_list.dart';
import 'package:anavandi_locator/data/models/bus_route.dart'; // Import the model
import 'package:anavandi_locator/presentation/widgets/bus_route_card.dart'; // Import the new widget

class HomeContent extends StatefulWidget {
  final VoidCallback onSubmit;
  final TextEditingController startPointController;
  final TextEditingController destinationController;
  final Function(List<BusRoute>) onRouteFound; // Receive a list of BusRoute

  const HomeContent({
    super.key,
    required this.onSubmit,
    required this.startPointController,
    required this.destinationController,
    required this.onRouteFound,
  });

  @override
  State<HomeContent> createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  final PlaceRepository _placeRepository = PlaceRepository();
  List<Place> _startPointSuggestions = [];
  List<Place> _destinationSuggestions = [];
  final FocusNode _startPointFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();
  OverlayEntry? _startPointOverlayEntry;
  OverlayEntry? _destinationOverlayEntry;
  final LayerLink _startPointLayerLink = LayerLink();
  final LayerLink _destinationLayerLink = LayerLink();
  List<BusRoute> _routes = []; // State to hold the list of BusRoute

  void _onStartPointChanged(String value) async {
    if (value.isEmpty) {
      _hideStartPointSuggestionsOverlay();
      return;
    }

    final suggestions = await _placeRepository.getPlacesByName(value);
    if (mounted) {
      setState(() {
        _startPointSuggestions = suggestions;
        if (suggestions.isNotEmpty) {
          _showStartPointSuggestionsOverlay();
        } else {
          _hideStartPointSuggestionsOverlay();
        }
      });
    }
  }

  void _onDestinationChanged(String value) async {
    if (value.isEmpty) {
      _hideDestinationSuggestionsOverlay();
      return;
    }

    final suggestions = await _placeRepository.getPlacesByName(value);
    if (mounted) {
      setState(() {
        _destinationSuggestions = suggestions;
        if (suggestions.isNotEmpty) {
          _showDestinationSuggestionsOverlay();
        } else {
          _hideDestinationSuggestionsOverlay();
        }
      });
    }
  }

  void _selectStartPointSuggestion(Place place) {
    widget.startPointController.text = place.placeName;
    _startPointSuggestions = [];
    _hideStartPointSuggestionsOverlay();
    _startPointFocusNode.unfocus();
  }

  void _selectDestinationSuggestion(Place place) {
    widget.destinationController.text = place.placeName;
    _destinationSuggestions = [];
    _hideDestinationSuggestionsOverlay();
    _destinationFocusNode.unfocus();
  }

  void _showStartPointSuggestionsOverlay() {
    _hideStartPointSuggestionsOverlay();

    if (_startPointSuggestions.isNotEmpty) {
      _startPointOverlayEntry = OverlayEntry(
        builder:
            (context) => Positioned(
              width: MediaQuery.of(context).size.width - 32,
              child: CompositedTransformFollower(
                link: _startPointLayerLink,
                showWhenUnlinked: false,
                offset: Offset(0, _startPointFocusNode.hasFocus ? 50 : 0),
                child: Material(
                  elevation: 4,
                  child: PlaceSuggestionList(
                    suggestions: _startPointSuggestions,
                    onSelected: _selectStartPointSuggestion,
                  ),
                ),
              ),
            ),
      );

      Overlay.of(context).insert(_startPointOverlayEntry!);
    }
  }

  void _showDestinationSuggestionsOverlay() {
    _hideDestinationSuggestionsOverlay();

    if (_destinationSuggestions.isNotEmpty) {
      _destinationOverlayEntry = OverlayEntry(
        builder:
            (context) => Positioned(
              width: MediaQuery.of(context).size.width - 32,
              child: CompositedTransformFollower(
                link: _destinationLayerLink,
                showWhenUnlinked: false,
                offset: Offset(0, _destinationFocusNode.hasFocus ? 50 : 0),
                child: Material(
                  elevation: 4,
                  child: PlaceSuggestionList(
                    suggestions: _destinationSuggestions,
                    onSelected: _selectDestinationSuggestion,
                  ),
                ),
              ),
            ),
      );

      Overlay.of(context).insert(_destinationOverlayEntry!);
    }
  }

  void _hideStartPointSuggestionsOverlay() {
    _startPointOverlayEntry?.remove();
    _startPointOverlayEntry = null;
  }

  void _hideDestinationSuggestionsOverlay() {
    _destinationOverlayEntry?.remove();
    _destinationOverlayEntry = null;
  }

  void updateRoute(List<BusRoute> routes) {
    setState(() {
      _routes = routes;
    });
  }

  @override
  void dispose() {
    _startPointFocusNode.dispose();
    _destinationFocusNode.dispose();
    _hideStartPointSuggestionsOverlay();
    _hideDestinationSuggestionsOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CompositedTransformTarget(
            link: _startPointLayerLink,
            child: CustomTextField(
              focusNode: _startPointFocusNode,
              controller: widget.startPointController,
              hintText: 'Enter Starting Point',
              prefixIcon: Icons.location_on,
              onChanged: _onStartPointChanged,
            ),
          ),
          const SizedBox(height: 16),
          CompositedTransformTarget(
            link: _destinationLayerLink,
            child: CustomTextField(
              focusNode: _destinationFocusNode,
              controller: widget.destinationController,
              hintText: 'Enter Destination',
              prefixIcon: Icons.flag,
              onChanged: _onDestinationChanged,
            ),
          ),
          const SizedBox(height: 24),
          SubmitButton(
            label: 'Submit',
            onPressed: () {
              widget.onSubmit(); // Call the onSubmit passed from HomePage
            },
          ),
          const SizedBox(height: 16),
          if (_routes.isNotEmpty)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _routes.length,
                itemBuilder: (context, index) {
                  final route = _routes[index];
                  return BusRouteCard(route: route);
                },
              ),
            )
          else
            const Text(
              'No route found between the selected points.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}
