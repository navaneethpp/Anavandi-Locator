// NotificationPage.dart

import 'package:flutter/material.dart';

class RecentPage extends StatefulWidget {
  const RecentPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RecentPageState createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> {
  // List of recent routes
  final List<String> recentRoutes = [
    'Route 1 - City Center to Uptown',
    'Route 5 - Suburb to Business District',
    'Route 8 - Westside to Airport',
  ];

  // Function to clear all recent routes
  void clearHistory() {
    setState(() {
      recentRoutes.clear(); // Clear all the routes in the list
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
              'Recent',
              style: TextStyle(color: Colors.white),
            ),
            Image.asset(
              'assets/logo_white.png', // Replace with the actual path to your logo
              width: 100, // Adjust size as needed
              height: 40,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ListView of recent routes with swipe to delete
                Expanded(
                  child: ListView.builder(
                    itemCount: recentRoutes.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(
                            recentRoutes[index]), // Unique key for each item
                        direction: DismissDirection
                            .endToStart, // Swipe from right to left
                        onDismissed: (direction) {
                          // Remove item from list when dismissed
                          setState(() {
                            recentRoutes.removeAt(index);
                          });

                          // Show a snackbar confirming the deletion
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${recentRoutes[index]} removed from history'),
                            ),
                          );
                        },
                        background: Container(
                          color: Colors.red, // Red background for swipe
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(
                              bottom: 16.0), // Space between cards
                          decoration: BoxDecoration(
                            color:
                                Colors.white, // White background for the card
                            borderRadius:
                                BorderRadius.circular(12), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: 0.3), // Light shadow for depth
                                blurRadius: 5, // Blur radius of the shadow
                                offset: const Offset(0, 2), // Shadow position
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(
                                16.0), // Padding inside the card
                            leading: const Icon(Icons.history),
                            title: Text(recentRoutes[index]),
                            onTap: () {
                              // Navigate to details or map view for selected route
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Positioned button at the bottom center
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: clearHistory,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red, // Red button to clear all
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Clear All History',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
