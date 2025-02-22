// textForBusDetails.dart

// This file defines a reusable StatelessWidget, `TextForBusDetails`, which is designed to display
// a label and its corresponding data in a consistent, styled format within the application,
// specifically intended for displaying details on the Bus Details page.

// Documentation:
//
// Widget Purpose:
// The `TextForBusDetails` widget is a simple yet versatile UI component created to present information
// in a structured label-data pair. It's used to display attributes of a bus, such as Registration Number,
// Unique Number, etc., on the Bus Details page.  This widget promotes code reusability and consistency
// in how such information is displayed throughout the application.
//
// Working:
// - The widget takes two required parameters: `labelText` (String) and `dataText` (String).
// - It uses a `Column` to arrange the label and data text vertically.
// - The `labelText` is displayed first, formatted with a bold font weight and a slightly smaller font size.
// - A `SizedBox` is used to create a small vertical space between the label and the data.
// - The `dataText` is displayed below the label, formatted with a normal font weight and a slightly larger font size.
// - Both label and data texts use a predefined `textColor` constant for consistent color theming.
//
// UI Structure:
// - Column: Arranges the label and data texts vertically.
//     - crossAxisAlignment: `CrossAxisAlignment.start` ensures that both the label and data texts are aligned to the leading edge (left in LTR languages), improving readability when labels and data have varying widths.
//     - Children:
//         - Text (Label): Displays the `labelText` with bold font weight and specific styling.
//         - SizedBox: Provides vertical spacing between the label and data.
//         - Text (Data): Displays the `dataText` with normal font weight and specific styling.
//
// Properties (Parameters):
// - labelText (String, required):
//   - Purpose:  The text to be used as the label for the information being displayed (e.g., "Registration Number", "Bus Type").
//   - Styling: Displayed in bold with a slightly smaller font size (16) and `textColor`.
//
// - dataText (String, required):
//   - Purpose: The actual data or value associated with the label (e.g., "AB1234", "Express").
//   - Styling: Displayed in normal font weight with a slightly larger font size (18) and `textColor`.
//
// Constants:
// - textColor: `const Color textColor = Colors.black;`
//   - Purpose: Defines the color of both the label and data text, ensuring consistent text color throughout the widget.
//   - Value: Set to `Colors.black`. This can be easily changed in `textForBusDetails.dart` to modify the text color across all instances of this widget.
//
// Usage:
// To use the `TextForBusDetails` widget, you need to provide both `labelText` and `dataText` as arguments. For example:
// ```dart
// TextForBusDetails(labelText: 'Registration Number:', dataText: bus.registrationNumber),
// ```
// This widget is particularly useful in detail pages or forms where structured display of label-value pairs is needed.
//
// Future Enhancements (Beyond the current implementation):
// -  More Styling Options:  Could be extended to allow for more customizable styling options (e.g., label color, data color, font family, text alignment) if more varied text display styles are required in the future.
// -  Icon Integration: Option to include an icon alongside the label if visual cues are desired.

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
