import 'package:flutter/material.dart';
import 'package:anavandi_locator/presentation/screens/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anavandi Locator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SafeArea(child: const HomePage()),
      debugShowCheckedModeBanner: false, // Removed the debugging badge
    );
  }
}
