import 'package:flutter/material.dart';
import 'package:anavandi_locator/common/widgets/custom_text_field.dart';
import 'package:anavandi_locator/common/widgets/submit_button.dart';
import 'package:anavandi_locator/data/models/place.dart';
import 'package:anavandi_locator/data/repositories/place_repository.dart';
import 'package:anavandi_locator/presentation/widgets/place_suggestion_list.dart';
import 'package:anavandi_locator/data/models/bus_route.dart';
import 'package:anavandi_locator/presentation/widgets/bus_route_card.dart';
import 'package:anavandi_locator/common/widgets/swap_button.dart';
import 'package:anavandi_locator/presentation/widgets/loading_indicator.dart';
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
  List<BusRoute> _filteredRoutes = []; // To store filtered routes
  bool _hasSearched = false;
  Timer? _noRouteTimer;
  bool _isLoading = false;

  // Filter options
  bool _showOnlyArrivingBuses = false;

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
      _applyFilters(); // Apply filters when routes are updated
      _isLoading = false;
      if (_routes.isNotEmpty) {
        _hasSearched = true;
        _noRouteTimer?.cancel();
      } else if (_hasSearched) {
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

  // Apply filters based on the current filter selections
  void _applyFilters() {
    if (_showOnlyArrivingBuses) {
      final startPoint = widget.startPointController.text.toLowerCase();
      _filteredRoutes =
          _routes.where((route) {
            // Check if any bus stop (except the first one) matches the starting point
            for (int i = 1; i < route.busStops.length; i++) {
              if (route.busStops[i].stopName.toLowerCase() == startPoint) {
                return true;
              }
            }
            return false;
          }).toList();
    } else {
      _filteredRoutes = List.from(_routes);
    }
  }

  // Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          showOnlyArrivingBuses: _showOnlyArrivingBuses,
          onShowOnlyArrivingBusesChanged: (value) {
            setState(() {
              _showOnlyArrivingBuses = value;
              _applyFilters();
            });
          },
        );
      },
    );
  }

  void _swapTextFields() {
    final String temp = widget.startPointController.text;
    widget.startPointController.text = widget.destinationController.text;
    widget.destinationController.text = temp;
  }

  Future<void> _fetchNearestBusStop() async {
    setState(() {
      _isLoading = true; // Show loading while fetching location and stop
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, handle appropriately
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Call your repository method to get the nearest place
      Place? nearestPlace = await _placeRepository.getNearestPlace(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (nearestPlace != null) {
        setState(() {
          widget.startPointController.text = nearestPlace.placeName;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find the nearest bus stop.')),
        );
      }
    } catch (e) {
      print("Error fetching nearest bus stop: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch nearest bus stop.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      child: Stack(
        children: [
          Padding(
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
                      FocusScope.of(
                        context,
                      ).requestFocus(_destinationFocusNode);
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _fetchNearestBusStop,
                    icon: const Icon(Icons.near_me),
                    label: const Text('Use Current Location'),
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
                  label: 'Find the Bus',
                  onPressed: () {
                    setState(() {
                      _hasSearched = true;
                      _isLoading = true;
                    });
                    widget.onSubmit();
                  },
                ),
                const SizedBox(height: 16),

                // Filter section and results
                if (_routes.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Results: ${_filteredRoutes.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.filter_list, size: 18),
                        label: const Text('Filter'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                        onPressed: _showFilterDialog,
                      ),
                    ],
                  ),

                const SizedBox(height: 8),

                if (_filteredRoutes.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredRoutes.length,
                      itemBuilder: (context, index) {
                        final route = _filteredRoutes[index];
                        return BusRouteCard(route: route);
                      },
                    ),
                  )
                else if (_hasSearched &&
                    _routes.isNotEmpty &&
                    _showOnlyArrivingBuses)
                  const Text(
                    'No buses found arriving at your starting point.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  )
                else if (_hasSearched && _routes.isEmpty)
                  Text(
                    'No route found between "${widget.startPointController.text}" and "${widget.destinationController.text}".',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }
}
