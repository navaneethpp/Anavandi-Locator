import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end, // Changed this line
      children: [
        Expanded(
          // Wrapped the image with Expanded
          child: Center(
            child: Image.asset('assets/logo.png', width: 300, height: 200),
          ),
        ),
        const Center(child: Text('Version: 0.2.8.3 alpha')),
      ],
    );
  }
}
