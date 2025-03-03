import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback? onPressed; // Callback function for button press
  final Widget child; // Widget to display inside the button (e.g., Text)

  const SubmitButton({
    super.key,
    this.onPressed,
    required this.child, // Make child a required parameter
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: child);
  }
}
