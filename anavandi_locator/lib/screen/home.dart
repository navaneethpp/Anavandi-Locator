// home.dart

import 'package:anavandi_locator/components/custom_app_bar.dart';
// import 'package:anavandi_locator/constants/images.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(
      title: "",
    ));
  }
}
