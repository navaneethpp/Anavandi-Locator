// about_page.dart

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
              'About',
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
      body: const Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Centering the "Our Team" text
                Center(
                  child: Text(
                    'Our Team',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Combined UI/UX Designer and Android Developer
                TeamMemberRole(
                  role: 'UI/UX Designer & Android Developer',
                  names: ['Navaneeth P P'],
                ),
                TeamMemberRole(
                  role: 'Web Developer',
                  names: ['Kripa K'],
                ),
                TeamMemberRole(
                  role: 'Back-End Developer',
                  names: ['Prajosh C', 'Pranav M K', 'Sanandh C P'],
                ),
              ],
            ),
          ),
          // Version Text Positioned at the Bottom Center
          Center(
            child: Align(
              alignment: Alignment
                  .bottomCenter, // Ensures the text is centered horizontally
              child: Text(
                'Version: 0.2.1 alpha', // Replace with your app's version number
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TeamMemberRole extends StatelessWidget {
  final String role;
  final List<String> names;

  const TeamMemberRole({
    super.key,
    required this.role,
    required this.names,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.cyanAccent),
          ),
          const SizedBox(height: 4),
          ...names.map(
            (name) => Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
