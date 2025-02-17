import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CompassWidget extends StatefulWidget {
  const CompassWidget({Key? key}) : super(key: key);

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  double? heading = 0;

  @override
  void initState() {
    super.initState();
    // Start listening to magnetometer events when the widget is initialized
    magnetometerEvents.listen((event) {
      setState(() {
        heading =
            calculateHeading(event); // Calculate heading from magnetometer data
      });
    });
  }

  // Calculate heading based on magnetometer event
  double calculateHeading(MagnetometerEvent event) {
    double angle = math.atan2(event.y, event.x);
    double degrees = (angle * 180 / math.pi) - 93;
    return (degrees * -1); // Invert the degree value for correct rotation
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RotationTransition(
          // Deprecated in the article, using AnimatedRotation instead for smoothness and consistency with previous implementations.
          turns: AlwaysStoppedAnimation(heading! /
              360), // Removed AnimatedRotation here, using outer AnimatedRotation for the whole widget now.
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Compass Background (Circle) - Keeping your design
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                ),
                // Red North Indicator (Icon) - Keeping your design
                Positioned(
                  top: 8,
                  child: Transform.rotate(
                    angle: 0,
                    child: const Icon(
                      Icons.navigation_rounded,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),
                ),
                // White South Indicator (Icon) - Keeping your design
                Positioned(
                  bottom: 8,
                  child: Transform.rotate(
                    angle: math.pi,
                    child: const Icon(
                      Icons.navigation_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Circular border for design - Keeping your design
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38, width: 2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
