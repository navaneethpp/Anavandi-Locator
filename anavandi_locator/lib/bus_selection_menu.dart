// bus_selection_menu.dart

import 'package:flutter/material.dart';
import 'BusDetailsPage.dart';

class BusSelectionMenu extends StatefulWidget {
  const BusSelectionMenu({super.key});

  @override
  _BusSelectionMenuState createState() => _BusSelectionMenuState();
}

class _BusSelectionMenuState extends State<BusSelectionMenu> {
  List<Map<String, String>> availableBuses = [];
  List<Map<String, String>> favoriteBuses = [];
  final TextEditingController startingPointController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

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

    setState(() {
      availableBuses = [
        {
          'registrationNumber': 'AB1234',
          'uniqueNumber': '001',
          'startingStation': 'Station A',
          'endingStation': 'Station B',
          'currentLocation': 'Near Station A',
          'arrivingTime': '7:30 AM',
          'busType': 'Express',
        },
        {
          'registrationNumber': 'CD5678',
          'uniqueNumber': '002',
          'startingStation': 'Station C',
          'endingStation': 'Station D',
          'currentLocation': 'Near Station C',
          'arrivingTime': '8:00 AM',
          'busType': 'Local',
        },
      ];
    });
  }

  void _toggleFavorite(Map<String, String> bus) {
    setState(() {
      if (favoriteBuses.contains(bus)) {
        favoriteBuses.remove(bus); // Remove from favorites
      } else {
        favoriteBuses.add(bus); // Add to favorites
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
                Navigator.pushNamed(context,
                    '/home'); // Replace '/home' with your desired route
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
                TextField(
                  controller: startingPointController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Starting Point',
                  ),
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
                TextField(
                  controller: destinationController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Destination',
                  ),
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BusDetailsPage(
                                    registrationNumber:
                                        bus['registrationNumber']!,
                                    uniqueNumber: bus['uniqueNumber']!,
                                    startingStation: bus['startingStation']!,
                                    endingStation: bus['endingStation']!,
                                    currentLocation: bus['currentLocation']!,
                                    arrivingTime: bus['arrivingTime']!,
                                    busType: bus['busType']!,
                                  ),
                                ),
                              );
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
}
