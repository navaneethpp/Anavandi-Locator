import 'package:flutter/material.dart';
import 'package:anavandi_locator/common/widgets/custom_text_field.dart';
import 'package:anavandi_locator/common/widgets/submit_button.dart';
import 'package:anavandi_locator/data/models/place.dart';
import 'package:anavandi_locator/data/repositories/place_repository.dart';
import 'package:anavandi_locator/presentation/widgets/place_suggestion_list.dart';
import 'package:anavandi_locator/data/models/bus_route.dart';
import 'package:anavandi_locator/presentation/widgets/bus_route_card.dart';
import 'package:anavandi_locator/common/widgets/swap_button.dart';
import 'dart:async';

class HomeContent extends StatefulWidget {
  final VoidCallback onSubmit;
  final TextEditingController startPointController;
  final TextEditingController destinationController;
  final Function(List<BusRoute>) onRouteFound;

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
  List<BusRoute> _routes = [];
  bool _hasSearched = false;
  Timer? _noRouteTimer;

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
    FocusScope.of(context).requestFocus(_destinationFocusNode);
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
      if (_routes.isNotEmpty) {
        _hasSearched = true;
        _noRouteTimer?.cancel(); // Cancel any existing timer
      } else if (_hasSearched) {
        // Start a timer to potentially hide the message
        _noRouteTimer = Timer(const Duration(seconds: 10), () {
          if (mounted && _routes.isEmpty) {
            setState(() {
              _hasSearched = false;
            });
          }
        });
      }
    });
  }

  void _swapTextFields() {
    final String temp = widget.startPointController.text;
    widget.startPointController.text = widget.destinationController.text;
    widget.destinationController.text = temp;
  }

  @override
  void dispose() {
    _startPointFocusNode.dispose();
    _destinationFocusNode.dispose();
    _hideStartPointSuggestionsOverlay();
    _hideDestinationSuggestionsOverlay();
    _noRouteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_startPointOverlayEntry != null) {
          _hideStartPointSuggestionsOverlay();
        }
        if (_destinationOverlayEntry != null) {
          _hideDestinationSuggestionsOverlay();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
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
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_destinationFocusNode);
                },
              ),
            ),
            const SizedBox(height: 8),
            SwapButton(onPressed: _swapTextFields),
            const SizedBox(height: 8),
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
              label: 'Find Bus Route',
              onPressed: () {
                setState(() {
                  _hasSearched = true;
                });
                widget.onSubmit();
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
            else if (_hasSearched)
              Text(
                'No route found between "${widget.startPointController.text}" and "${widget.destinationController.text}".',
                style: const TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center, // Added to center the text
              ),
          ],
        ),
      ),
    );
  }
}
