import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text(
            'Anavandi Locator',
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(child: Text('Version: 0.2.5 beta')),
      ],
    );
  }
}
