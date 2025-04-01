// In data_display_widget.dart
import 'package:flutter/material.dart';

class DataDisplayWidget extends StatelessWidget {
  final String? arrivalTime;
  final String? nearestStopName;

  const DataDisplayWidget({super.key, this.arrivalTime, this.nearestStopName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 100, // Increased height to accommodate the new text
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
            if (arrivalTime != null)
              Text(
                'Arriving in: $arrivalTime',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            else
              const Text(
                'Finding Arrival Time...',
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            if (nearestStopName != null)
              Text(
                'Nearest Stop: $nearestStopName',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              )
            else
              const Text(
                'Finding Nearest Stop...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
