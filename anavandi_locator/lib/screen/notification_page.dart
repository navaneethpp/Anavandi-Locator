// notification_page.dart

// This page displays a list of in-app notifications to the user.
// It provides a way to show important updates, alerts, or messages within the application.
// Users can view a list of notifications and clear them all at once.

// Documentation:
//
// Page Purpose:
// This page serves as the notification center for the application. It's designed to inform users
// about important events such as bus route updates, new features, scheduled maintenance,
// or any other relevant alerts.  The page displays these notifications in a clear, chronological list.
//
// Working:
// - Data Source: Currently uses a static list `notifications` of `Map<String, String>` to simulate notifications.
//   In a real application, notifications would likely be fetched from a backend service or local database.
// - State Management: Uses StatefulWidget (`NotificationPage` and `_NotificationPageState`) to manage the list of notifications.
//   The `_NotificationPageState` holds the `notifications` list and the `_clearNotifications` function to update the UI.
// - UI Structure:
//     - Scaffold: Provides the basic page structure with a transparent background.
//     - AppBar: Contains the title 'Notifications' and the application logo on the right.
//     - Stack: Used as the main body container to overlay the "Clear All" button at the bottom.
//     - Conditional Content Display: Checks if `notifications` list is empty.
//         - If empty: Displays a centered Text widget indicating "No notifications available."
//         - If not empty: Uses ListView.builder to efficiently render a scrollable list of notifications.
//     - ListView.builder: Dynamically builds the list of notifications based on the `notifications` list.
//         - Item Builder: For each notification in the list, it creates a `NotificationItem` widget.
//     - NotificationItem Widget: A custom StatelessWidget (defined below) responsible for displaying a single notification.
//         - Card: Provides a styled container for each notification.
//         - Padding: Adds spacing within the Card.
//         - Row: Arranges the notification elements horizontally (Icon, Text content, Time).
//         - Icon: Displays a notification icon (Icons.notifications).
//         - Expanded Column: Holds the notification title (bold text) and message (regular text), taking up available space.
//         - Time Text: Displays the notification time (grey, smaller text) on the right side.
//     - "Clear All" Button: Positioned at the bottom center of the Stack.
//         - ElevatedButton: Used for the button, styled with padding, background color, and rounded corners.
//         - `_clearNotifications` Function: Called when the "Clear All" button is pressed. It clears the `notifications` list and calls `setState` to rebuild the UI, effectively removing all notifications from the display.
//
// Future Enhancements (Beyond the current implementation):
// - Real-time Notifications: Integrate with a backend service (e.g., Firebase Cloud Messaging) to receive and display real-time push notifications.
// - Persistent Storage: Store notifications locally (e.g., using shared_preferences or a local database) so they persist across app sessions.
// - Mark as Read/Delete Individual Notifications: Implement functionality to mark notifications as read or delete individual notifications.
// - Notification Details Page:  For more complex notifications, tapping on a notification could navigate to a detailed notification page.
// - Notification Types/Categories: Categorize notifications and allow users to filter or customize notification settings.

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notification Screen',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotificationPage(),
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Sample list of notifications
  List<Map<String, String>> notifications = [
    {
      'title': 'Bus Route Update',
      'message': 'Your selected bus route has been updated.',
      'time': '2 minutes ago',
    },
    {
      'title': 'New Feature Added',
      'message': 'We have added new features to the app.',
      'time': '10 minutes ago',
    },
    {
      'title': 'Maintenance Scheduled',
      'message': 'The app will undergo maintenance at midnight.',
      'time': '1 hour ago',
    },
    {
      'title': 'New Bus Available',
      'message': 'A new bus has been added to the route you follow.',
      'time': 'Yesterday',
    },
  ];

  // Function to clear all notifications
  void _clearNotifications() {
    setState(() {
      notifications.clear(); // Clear all notifications
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
              'Notifications',
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
          notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications available.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    var notification = notifications[index];
                    return NotificationItem(
                      title: notification['title']!,
                      message: notification['message']!,
                      time: notification['time']!,
                    );
                  },
                ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width *
                0.35, // Center the button horizontally
            child: ElevatedButton(
              onPressed: _clearNotifications,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Clear All',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String time;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(
              Icons.notifications,
              color: Colors.blue,
              size: 30.0,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
