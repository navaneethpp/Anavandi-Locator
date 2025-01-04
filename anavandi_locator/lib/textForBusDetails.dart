// textForBusDetails.dart

import 'package:flutter/material.dart';

const Color textColor = Colors.black; // Declare the text color as a constant

// This widget displays a single text label with customizable styling
class TextForBusDetails extends StatelessWidget {
  final String label;
  final bool isBold; // New parameter to decide text weight

  const TextForBusDetails({
    super.key,
    required this.label,
    this.isBold = false, // Default to bold text
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 18,
        color: textColor,
        fontWeight:
            isBold ? FontWeight.bold : FontWeight.normal, // Conditional styling
      ),
    );
  }
}
