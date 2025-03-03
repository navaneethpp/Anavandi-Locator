import 'package:flutter/material.dart';

class CenterOnBusButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CenterOnBusButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.blue,
      child: const Icon(Icons.location_searching),
      tooltip: "Center the bus",
    );
  }
}
