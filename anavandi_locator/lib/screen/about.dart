import 'package:anavandi_locator/constants/names.dart';
import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Names.appName,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        Text(
          'Version: 0.2.5 beta',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }
}
