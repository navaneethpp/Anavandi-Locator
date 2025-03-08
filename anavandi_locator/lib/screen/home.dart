// home.dart
import 'package:anavandi_locator/widgets/app_text_field.dart';
import 'package:anavandi_locator/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:anavandi_locator/functions/home_functions.dart';
import 'package:anavandi_locator/widgets/icon_button_widget.dart';
import 'package:anavandi_locator/widgets/submit_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
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
      return [];
    }
    final Uri url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$input&countrycodes=in&format=json&limit=5',
    );
    print('Nominatim API URL: ${url.toString()}');

    final response = await http.get(
      url,
      headers: {'User-Agent': 'AnavandiLocatorApp'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item['display_name'].toString()).toList();
    } else {
      print('Failed to fetch suggestions: ${response.statusCode}');
      return [];
    }
  }

  void _selectSuggestion(String suggestion, bool isStartTextField) {
    setState(() {
      String lowercaseSuggestion = suggestion.toLowerCase();
      String truncatedSuggestion = lowercaseSuggestion;

      int commaIndex = lowercaseSuggestion.indexOf(',');
      if (commaIndex != -1) {
        truncatedSuggestion =
            lowercaseSuggestion.substring(0, commaIndex).trim();
      }

      if (isStartTextField) {
        _startingPoint = truncatedSuggestion;
        _startController.text = suggestion;
        _suggestionsStart = [];
      } else {
        _destination = truncatedSuggestion;
        _destController.text = suggestion;
        _suggestionsDest = [];
      }
    });
  }

  Future<void> _fetchBusDataFromFirestore(
    String startingPoint,
    String destination,
  ) async {
    setState(() {
      _busList = [];
      _isLoading = true;
    });

    print('Searching for buses from: "$startingPoint" to "$destination"');

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('assignData')
              .where('startingPoint', isEqualTo: startingPoint)
              .where('endingPoint', isEqualTo: destination)
              .get();

      print('Number of documents found: ${querySnapshot.docs.length}');

      setState(() {
        _busList = querySnapshot.docs;
        _isLoading = false;
      });
      if (_busList.isEmpty) {
        print('No buses found for this route (after query).');
      } else {
        print('Found ${_busList.length} buses (after query).');
        if (_busList.isNotEmpty) {
          DocumentSnapshot firstBus = _busList.first;
          Map<String, dynamic> busData =
              firstBus.data() as Map<String, dynamic>;
          print('Example bus data: ${busData}');
        }
      }
    } catch (e) {
      print('Error fetching bus data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Removed Expanded Widget Here:
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
                          _suggestionsStart = [];
                          _hideOverlayStart();
                        } else if (_suggestionsStart.isNotEmpty) {
                          _showOverlaySuggestions(
                            _suggestionsStart,
                            _layerLinkStart,
                            true,
                          );
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
                          _suggestionsDest = [];
                          _hideOverlayDest();
                        } else if (_suggestionsDest.isNotEmpty) {
                          _showOverlaySuggestions(
                            _suggestionsDest,
                            _layerLinkDest,
                            false,
                          );
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
                // Removed SizedBox(height: 20.0) here
              ],
            ),
          ),
          Expanded(child: BusListWidget(busList: _busList)),
        ],
      ),
    );
  }
}
