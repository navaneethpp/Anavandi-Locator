// recent_page.dart

// This page displays a list of recently accessed bus routes by the user.
// It allows users to review their recent searches and provides functionality to clear the history.
// Each recent route is displayed as a swipeable card that can be dismissed to remove it individually,
// and a "Clear All History" button is available to clear the entire recent routes list.

// Documentation:
//
// Page Purpose:
// The RecentPage provides users with a convenient way to access their recently viewed bus routes.
// This enhances user experience by allowing quick revisits to previously searched routes without needing to re-enter search criteria.
//
// Working:
// - Data Source: Uses a list `recentRoutes` of type `String` to store the names of recently accessed routes.
//   In a real application, this list could be populated from local storage (e.g., SharedPreferences, SQLite database)
//   to persist recent routes across app sessions. Currently, it uses a static list for demonstration.
// - State Management: Uses StatefulWidget (`RecentPage` and `_RecentPageState`) to manage the list of recent routes.
//   The `_RecentPageState` holds the `recentRoutes` list and functions to update it (clear history, remove on swipe).
// - UI Structure:
//     - Scaffold: Provides the basic page structure with a transparent background.
//     - AppBar: Contains the title 'Recent' and the application logo on the right.
//     - Stack: Used as the main body container to allow positioning of the "Clear All History" button at the bottom.
//     - Padding: Provides padding around the main content within the Stack.
//     - Column: Arranges the content vertically within the Padding.
//     - Expanded & ListView.builder:  Used to create a scrollable list of recent routes. `ListView.builder` efficiently renders the list items.
//     - Dismissible: Wraps each recent route item to enable swipe-to-delete functionality.
//         - Key: Each `Dismissible` widget is given a unique `Key` based on the `recentRoutes` item to correctly identify it during deletion.
//         - Direction: Set to `DismissDirection.endToStart` for right-to-left swipe.
//         - onDismissed: Callback function triggered when a swipe-to-delete is performed.
//             - Removes the swiped route from the `recentRoutes` list using `setState` to update the UI.
//             - Shows a `SnackBar` to confirm the deletion to the user.
//         - background: Defines the background UI that appears during the swipe (red `Container` with a delete icon).
//         - child: Contains the UI for each recent route item, which is a `Container` styled to look like a card.
//             - Container: Provides styling (background color, rounded corners, shadow) for each route card.
//             - ListTile: Displays the route information within the card.
//                 - leading: Displays a history icon (Icons.history).
//                 - title: Shows the route name from the `recentRoutes` list.
//                 - onTap:  Currently empty, but intended for future navigation to the details or map view of the selected recent route.
//     - "Clear All History" Button: Positioned at the bottom center of the Stack.
//         - ElevatedButton: Used for the button, styled with red color, elevation, and rounded corners.
//         - `clearHistory` Function: Called when the "Clear All History" button is pressed. It clears the `recentRoutes` list and calls `setState` to rebuild the UI, effectively clearing the entire history.
//
// Future Enhancements (Beyond the current implementation):
// - Persistent Storage: Implement local storage to save and load recent routes across app sessions.
// - Navigation on Tap: Implement navigation to the `BusDetailsPage` or a map view when a recent route item is tapped.
// - Dynamic Recent Routes: In a real app, recent routes would be dynamically added to the `recentRoutes` list whenever a user searches for or views bus route details.

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
