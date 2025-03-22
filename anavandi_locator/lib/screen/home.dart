// home.dart
import 'package:anavandi_locator/widgets/app_text_field.dart';
import 'package:anavandi_locator/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:anavandi_locator/functions/home_functions.dart';
import 'package:anavandi_locator/widgets/icon_button_widget.dart';
import 'package:anavandi_locator/widgets/submit_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anavandi_locator/widgets/bus_list_widget.dart';

class Home extends StatefulWidget {
  final LatLng? userLocation;

  const Home({super.key, this.userLocation});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _startingPoint = '';
  String _destination = '';
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  OverlayEntry? _overlayEntryStart;
  OverlayEntry? _overlayEntryDest;
  final LayerLink _layerLinkStart = LayerLink();
  final LayerLink _layerLinkDest = LayerLink();

  List<String> _suggestionsStart = [];
  List<String> _suggestionsDest = [];
  bool _isStartFocused = false;
  bool _isDestFocused = false;
  List<DocumentSnapshot> _busList = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _startController.dispose();
    _destController.dispose();
    _hideOverlayStart();
    _hideOverlayDest();
    super.dispose();
  }

  void _showOverlaySuggestions(
    List<String> suggestions,
    LayerLink layerLink,
    bool isStart,
  ) {
    _hideOverlayStart();
    _hideOverlayDest();

    if (suggestions.isEmpty) {
      return; // Don't show empty overlay
    }

    OverlayEntry newOverlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: MediaQuery.of(context).size.width * 0.8,
          child: CompositedTransformFollower(
            link: layerLink,
            offset: const Offset(0, 50),
            child: Material(
              elevation: 4.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                margin: const EdgeInsets.only(top: 2.0),
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                // Set a max height for the suggestions list
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  // Allow scrolling if there are many suggestions
                  physics: const ClampingScrollPhysics(),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true, // Make the list items more compact
                      title: Text(suggestions[index]),
                      onTap: () {
                        _selectSuggestion(suggestions[index], isStart);
                        if (isStart) {
                          _hideOverlayStart();
                        } else {
                          _hideOverlayDest();
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    if (isStart) {
      _overlayEntryStart = newOverlayEntry;
      Overlay.of(context).insert(_overlayEntryStart!);
    } else {
      _overlayEntryDest = newOverlayEntry;
      Overlay.of(context).insert(_overlayEntryDest!);
    }
  }

  void _hideOverlayStart() {
    _overlayEntryStart?.remove();
    _overlayEntryStart = null;
  }

  void _hideOverlayDest() {
    _overlayEntryDest?.remove();
    _overlayEntryDest = null;
  }

  void _updateStartSuggestions(String input) async {
    final suggestions = await _fetchPlaceSuggestions(input);
    setState(() {
      _suggestionsStart = suggestions;
    });
    if (_isStartFocused) {
      _showOverlaySuggestions(_suggestionsStart, _layerLinkStart, true);
    } else {
      _hideOverlayStart();
    }
  }

  void _updateDestSuggestions(String input) async {
    final suggestions = await _fetchPlaceSuggestions(input);
    setState(() {
      _suggestionsDest = suggestions;
    });
    if (_isDestFocused) {
      _showOverlaySuggestions(_suggestionsDest, _layerLinkDest, false);
    } else {
      _hideOverlayDest();
    }
  }

  Future<List<String>> _fetchPlaceSuggestions(String input) async {
    if (input.isEmpty) {
      // If input is empty, show all places (limited to reasonable number)
      return await _loadAllPlaces();
    }

    try {
      // Use array-contains or array-contains-any if you have keyword array fields
      // Otherwise, try a simple text search
      QuerySnapshot querySnapshot;

      // First approach: Search for places where placeName contains the input
      // Note: Firestore doesn't have native "contains" query, so we have to be creative
      // We'll try to get places that start with the input and filter client-side
      querySnapshot =
          await FirebaseFirestore.instance
              .collection('placeData')
              .orderBy('placeName')
              .get();

      // Client-side filtering to find places containing the input
      List<String> filteredPlaces =
          querySnapshot.docs
              .map((doc) => doc['placeName'] as String)
              .where(
                (placeName) =>
                    placeName.toLowerCase().contains(input.toLowerCase()),
              )
              .toList();

      // Limit results to a reasonable number
      if (filteredPlaces.length > 10) {
        filteredPlaces = filteredPlaces.sublist(0, 10);
      }
      return filteredPlaces;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> _loadAllPlaces() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('placeData')
              .orderBy('placeName')
              .limit(15) // Limit to a reasonable number
              .get();

      List<String> places =
          querySnapshot.docs.map((doc) => doc['placeName'] as String).toList();
      return places;
    } catch (e) {
      return [];
    }
  }

  Future<void> _selectSuggestion(
    String suggestion,
    bool isStartTextField,
  ) async {
    try {
      // Query Firestore to get the full place data
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('placeData')
              .where('placeName', isEqualTo: suggestion)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot placeDoc = querySnapshot.docs.first;
        Map<String, dynamic> placeData =
            placeDoc.data() as Map<String, dynamic>;

        // You could print or use the coordinates here

        setState(() {
          if (isStartTextField) {
            _startingPoint = suggestion;
            _startController.text = suggestion;
            _suggestionsStart = [];
          } else {
            _destination = suggestion;
            _destController.text = suggestion;
            _suggestionsDest = [];
          }
        });
      } else {
        // print('Place not found in Firestore: $suggestion');
      }
    } catch (e) {
      // print('Error selecting suggestion: $e');
    }
  }

  Future<void> _fetchBusDataFromFirestore(
    String startingPoint,
    String destination,
  ) async {
    setState(() {
      _busList = [];
      _isLoading = true;
    });

    try {
      String trimmedStart = startingPoint.trim().toLowerCase();
      String trimmedDest = destination.trim().toLowerCase();

      QuerySnapshot allRoutesSnapshot =
          await FirebaseFirestore.instance.collection('assignData').get();

      List<DocumentSnapshot> filteredDocs =
          allRoutesSnapshot.docs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            if (!data.containsKey('startingPoint') ||
                !data.containsKey('endingPoint')) {
              return false;
            }

            String docStart =
                (data['startingPoint'] as String).trim().toLowerCase();
            String docEnd =
                (data['endingPoint'] as String).trim().toLowerCase();

            bool matches = docStart == trimmedStart && docEnd == trimmedDest;

            if (matches) {
              // print(
              //   'Found match (case-insensitive and trimmed): ${data['startingPoint']} to ${data['endingPoint']}',
              // );
            }

            return matches;
          }).toList();

      setState(() {
        _busList = filteredDocs;
        _isLoading = false;
      });

      if (_busList.isEmpty) {
        try {
          QuerySnapshot exampleSnapshot =
              await FirebaseFirestore.instance
                  .collection('assignData')
                  .limit(5)
                  .get();

          for (var doc in exampleSnapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          }
        } catch (e) {
          // print('Error fetching example routes: $e');
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: 'No Buses Found',
              content:
                  'No buses found for route from "$trimmedStart" to "$trimmedDest".',
            );
          },
        );
      } else {
        if (_busList.isNotEmpty) {
          DocumentSnapshot firstBus = _busList.first;
          Map<String, dynamic> busData =
              firstBus.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: 'Error',
            content: 'Failed to fetch bus data: $e',
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CompositedTransformTarget(
                  link: _layerLinkStart,
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {
                        _isStartFocused = hasFocus;
                        if (!hasFocus) {
                          // Delay hiding to allow for tap
                          Future.delayed(const Duration(milliseconds: 200), () {
                            setState(() {
                              _hideOverlayStart();
                            });
                          });
                        } else {
                          // Show suggestions immediately when field is focused
                          _updateStartSuggestions(_startController.text);
                        }
                      });
                    },
                    child: AppTextField(
                      hintText: 'Starting Point',
                      isDispose: true,
                      controller: _startController,
                      onTextChanged: (text) {
                        setState(() {
                          _startingPoint = text;
                        });
                        _updateStartSuggestions(text);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: IconButtonWidget(
                      iconData: Icons.swap_vert,
                      onPressed: () {
                        swapTextFields(
                          currentStartingPoint: _startingPoint,
                          currentDestination: _destination,
                          startController: _startController,
                          destController: _destController,
                          setStateCallback: setState,
                          updateStartingPoint:
                              (value) => _startingPoint = value,
                          updateDestination: (value) => _destination = value,
                        );
                      },
                    ),
                  ),
                ),
                CompositedTransformTarget(
                  link: _layerLinkDest,
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {
                        _isDestFocused = hasFocus;
                        if (!hasFocus) {
                          // Delay hiding to allow for tap
                          Future.delayed(const Duration(milliseconds: 200), () {
                            setState(() {
                              _hideOverlayDest();
                            });
                          });
                        } else {
                          // Show suggestions immediately when field is focused
                          _updateDestSuggestions(_destController.text);
                        }
                      });
                    },
                    child: AppTextField(
                      hintText: 'Destination',
                      isDispose: true,
                      controller: _destController,
                      onTextChanged: (text) {
                        setState(() {
                          _destination = text;
                        });
                        _updateDestSuggestions(text);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                SubmitButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _hideOverlayStart();
                    _hideOverlayDest();
                    if (_startingPoint.isEmpty || _destination.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomAlertDialog(
                            title: 'Error',
                            content:
                                'Please enter both starting point and destination.',
                          );
                        },
                      );
                    } else {
                      _fetchBusDataFromFirestore(_startingPoint, _destination);
                    }
                  },
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                          : const Text('Submit'),
                ),
              ],
            ),
          ),
          Expanded(child: BusListWidget(busList: _busList)),
        ],
      ),
    );
  }
}
