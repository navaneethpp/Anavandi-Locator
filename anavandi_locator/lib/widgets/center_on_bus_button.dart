import 'package:flutter/material.dart';

class CenterOnBusButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CenterOnBusButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.blue,
      tooltip: "Center the bus",
      child: const Icon(Icons.location_searching),
    );
  }
}
