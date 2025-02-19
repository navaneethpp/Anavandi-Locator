// bus_selection_menu.dart
// This page include the entrance text field

import 'package:anavandi_locator/screen/bus_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:string_extensions/string_extensions.dart'; // Import string_extensions

class BusSelectionMenu extends StatefulWidget {
  const BusSelectionMenu({super.key});

  @override
  _BusSelectionMenuState createState() => _BusSelectionMenuState();
}

class _BusSelectionMenuState extends State<BusSelectionMenu> {
  List<Map<String, String>> availableBuses = [];
  List<Map<String, String>> favoriteBuses = [];
  TextEditingController startingPointController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  List<String> allDepotNames = [];
  List<String> startingSuggestionList = [];
  List<String> destinationSuggestionList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDepotNames();
  }

  Future<void> _fetchDepotNames() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Depot').get();

      allDepotNames = snapshot.docs
          .map((doc) {
            return doc.data()['name'] as String? ?? '';
          })
          .where((name) => name.isNotEmpty)
          .toList();
      allDepotNames.sort();
    } catch (e) {
      print('Error fetching depot names: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load depot names.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateStartingSuggestionList(String input) {
    setState(() {
      if (input.isEmpty) {
        startingSuggestionList = [];
      } else {
        startingSuggestionList = allDepotNames
            .where((depotName) =>
                depotName.toLowerCase().contains(input.toLowerCase()))
            .toList();
      }
    });
  }

  void _updateDestinationSuggestionList(String input) {
    setState(() {
      if (input.isEmpty) {
        destinationSuggestionList = [];
      } else {
        destinationSuggestionList = allDepotNames
            .where((depotName) =>
                depotName.toLowerCase().contains(input.toLowerCase()))
            .toList();
      }
    });
  }

  void findBuses() {
    if (startingPointController.text.isEmpty ||
        destinationController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
            'Please fill in both Starting Point and Destination.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Validation check for if user enters starting point and destination same:
    if (startingPointController.text.toLowerCase() ==
        destinationController.text.toLowerCase()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
            'Starting point and Destination can\'t be the same.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return; // Exit the function if validation fails
    }

    // --- Location Database Validation ---
    String startingPoint = startingPointController.text.trim().toLowerCase();
    String destinationPoint = destinationController.text.trim().toLowerCase();

    bool isStartingPointValid = false;
    bool isDestinationValid = false;

    for (String depotName in allDepotNames) {
      if (depotName.toLowerCase() == startingPoint) {
        isStartingPointValid = true;
      }
      if (depotName.toLowerCase() == destinationPoint) {
        isDestinationValid = true;
      }
    }

    if (!isStartingPointValid || !isDestinationValid) {
      String errorMessage = '';
      if (!isStartingPointValid && !isDestinationValid) {
        errorMessage =
            'Starting point and Destination locations are not found in our database.';
      } else if (!isStartingPointValid) {
        errorMessage = 'Starting point location is not found in our database.';
      } else {
        errorMessage = 'Destination location is not found in our database.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Not Found'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return; // Exit if location is not valid
    }
    // --- End Location Database Validation ---

    setState(() {
      availableBuses = [
        {
          'registrationNumber': 'AB1234',
          'uniqueNumber': '001',
          'startingStation':
              startingPointController.text, // Use input from text fields
          'endingStation':
              destinationController.text, // Use input from text fields
          'currentLocation': 'Near ${startingPointController.text}',
          'arrivingTime': '7:30 AM',
          'busType': 'Express',
        },
        {
          'registrationNumber': 'CD5678',
          'uniqueNumber': '002',
          'startingStation':
              startingPointController.text, // Use input from text fields
          'endingStation':
              destinationController.text, // Use input from text fields
          'currentLocation': 'Near ${startingPointController.text}',
          'arrivingTime': '8:00 AM',
          'busType': 'Local',
        },
      ];
    });
  }

  void _toggleFavorite(Map<String, String> bus) {
    setState(() {
      if (favoriteBuses.contains(bus)) {
        favoriteBuses.remove(bus);
      } else {
        favoriteBuses.add(bus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Find Your Bus',
              style: TextStyle(color: Colors.white),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
              child: Image.asset(
                'assets/logo_white.png',
                width: 100,
                height: 40,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 0),
                if (isLoading)
                  const LinearProgressIndicator(
                      color: Colors.cyanAccent) // Loading indicator
                else
                  Column(
                    // Wrap TextField and suggestions in a Column
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        textCapitalization: TextCapitalization.characters,
                        controller: startingPointController,
                        style: const TextStyle(
                            color: Colors.black), // Adjusted text color
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Starting Point',
                          hintStyle: TextStyle(
                              color: Colors.grey), // Adjusted hint text color
                        ),
                        onChanged: (value) {
                          _updateStartingSuggestionList(value);
                        },
                      ),
                      if (startingSuggestionList.isNotEmpty)
                        _buildSuggestionList(
                            startingSuggestionList, startingPointController,
                            () {
                          setState(() {
                            startingSuggestionList =
                                []; // Clear suggestions on selection
                          });
                        }),
                    ],
                  ),
                const SizedBox(height: 8),
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.swap_vert),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        final temp = startingPointController.text;
                        startingPointController.text =
                            destinationController.text;
                        destinationController.text = temp;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                if (isLoading)
                  const SizedBox
                      .shrink() // No TextField for Destination while loading
                else
                  Column(
                    // Wrap TextField and suggestions in a Column
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: destinationController,
                        style: const TextStyle(
                            color: Colors.black), // Adjusted text color
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Destination',
                          hintStyle: TextStyle(
                              color: Colors.grey), // Adjusted hint text color
                        ),
                        onChanged: (value) {
                          _updateDestinationSuggestionList(value);
                        },
                      ),
                      if (destinationSuggestionList.isNotEmpty)
                        _buildSuggestionList(
                            destinationSuggestionList, destinationController,
                            () {
                          setState(() {
                            destinationSuggestionList =
                                []; // Clear suggestions on selection
                          });
                        }),
                    ],
                  ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: findBuses,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Find Buses',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (availableBuses.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: availableBuses.length,
                      itemBuilder: (context, index) {
                        final bus = availableBuses[index];
                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              'Bus ${bus['uniqueNumber']} - ${bus['arrivingTime']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                favoriteBuses.contains(bus)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: favoriteBuses.contains(bus)
                                    ? Colors.red
                                    : null,
                              ),
                              onPressed: () {
                                _toggleFavorite(bus);
                              },
                            ),
                            onTap: () async {
                              String destinationName = bus['endingStation']!;
                              double? endLatitude;
                              double? endLongitude;

                              try {
                                QuerySnapshot<Map<String, dynamic>>
                                    depotSnapshot = await FirebaseFirestore
                                        .instance
                                        .collection('Depot')
                                        .where('name',
                                            isEqualTo: destinationName)
                                        .get();

                                if (depotSnapshot.docs.isNotEmpty) {
                                  var depotData =
                                      depotSnapshot.docs.first.data();
                                  List<dynamic> locationArray =
                                      depotData['location'];
                                  if (locationArray.length == 2) {
                                    endLatitude = locationArray[0];
                                    endLongitude = locationArray[1];
                                  } else {
                                    throw Exception(
                                        "Invalid location array format in Firestore");
                                  }
                                } else {
                                  throw Exception(
                                      "Depot '$destinationName' not found in Firestore");
                                }
                              } catch (e) {
                                print("Error fetching depot location: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Failed to load location for $destinationName')),
                                );
                                return; // Exit onTap if location fetch fails
                              }

                              if (endLatitude != null && endLongitude != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BusDetailsPage(
                                      registrationNumber:
                                          bus['registrationNumber']!,
                                      uniqueNumber: bus['uniqueNumber']!,
                                      startingStation:
                                          startingPointController.text,
                                      endingStation: destinationController.text,
                                      currentLocation: bus['currentLocation']!,
                                      arrivingTime: bus['arrivingTime']!,
                                      busType: bus['busType']!,
                                      endLatitude: endLatitude!,
                                      endLongitude: endLongitude!,
                                      userStartingStation:
                                          startingPointController.text,
                                      userEndingStation:
                                          destinationController.text,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build suggestion list
  Widget _buildSuggestionList(List<String> suggestionList,
      TextEditingController controller, VoidCallback onSuggestionSelected) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(5.0),
      ),
      margin: const EdgeInsets.only(top: 2.0),
      height: 150.0, // Fixed height for suggestion list
      child: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          final depotName = suggestionList[index];
          return ListTile(
            title: Text(depotName.toTitleCase, // Convert to title case here
                style: const TextStyle(color: Colors.white)),
            onTap: () {
              controller.text = depotName;
              onSuggestionSelected(); // Callback to clear suggestion list in parent widget
            },
          );
        },
      ),
    );
  }
}
