// textForBusDetails.dart

import 'package:flutter/material.dart';

const Color textColor = Colors.black;

class TextForBusDetails extends StatelessWidget {
  final String labelText; // Changed from 'label' to 'labelText'
  final String dataText; // Added 'dataText' for the data part

  const TextForBusDetails({
    super.key,
    required this.labelText, // Now required labelText
    required this.dataText, // Now required dataText
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // Using Column to arrange label and data vertically
      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
      children: [
        Text(
          // Label text (bold)
          labelText, // Use labelText
          style: const TextStyle(
            fontSize: 16, // Slightly smaller for labels
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2), // Small spacing between label and data
        Text(
          // Data text (normal weight)
          dataText, // Use dataText
          style: const TextStyle(
            fontSize: 18, // Slightly larger for data
            color: textColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
