import 'package:flutter/material.dart';
import 'package:anavandi_locator/utils/version.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          // Wrapped the image with Expanded
          child: Center(
            child: Image.asset('assets/logo.png', width: 300, height: 200),
          ),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, color: Colors.blue),
              SizedBox(width: 5),
              Text('anavandiproject@gmail.com', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
        Center(
          child: Text(
            'Version: ${Version.currentVersion}',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
