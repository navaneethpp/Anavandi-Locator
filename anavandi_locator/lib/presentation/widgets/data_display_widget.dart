// In data_display_widget.dart
import 'package:flutter/material.dart';

class DataDisplayWidget extends StatelessWidget {
  final String? stopName;
  final bool isNextStop;

  const DataDisplayWidget({
    super.key,
    this.stopName,
    this.isNextStop = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 60, // Reduced height as arrival time is removed
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          bottomLeft: Radius.circular(8.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (stopName != null)
              Text(
                '${isNextStop ? 'Next Stop' : 'Nearest Stop'}: $stopName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ), // Slightly increased font size
              )
            else
              Text(
                'Finding ${isNextStop ? 'Next Stop' : 'Nearest Stop'}...',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }
}
