// NotificationPage.dart

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
      home: NotificationPage(),
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
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
