// compass_widget.dart

// This widget implements a digital compass using magnetometer sensor data.
// It displays a rotating compass needle that points towards magnetic north.
// The compass uses the `sensors_plus` package to access magnetometer sensor readings
// and performs calculations to determine the device's heading.

// Documentation:
//
// Widget Purpose:
// The CompassWidget is a UI component designed to display a digital compass within the application.
// It leverages the device's magnetometer sensor to detect magnetic field and calculate the heading direction.
// This widget is useful for orienting the user and providing directional context within the app,
// particularly in map-based or location-aware features.
//
// Working:
// - Sensor Data Acquisition:
//     - Utilizes the `sensors_plus` package to access magnetometer sensor events.
//     - In `initState`, it starts listening to `magnetometerEvents` stream.
//     - For each magnetometer event received, the `setState` is called to trigger a UI rebuild with updated heading.
// - Heading Calculation:
//     - `calculateHeading(MagnetometerEvent event)` function is responsible for calculating the heading angle in degrees
//       from the raw magnetometer data (x, y, z components from `MagnetometerEvent`).
//     - It uses `math.atan2(event.y, event.x)` to get the angle in radians from the x and y components of the magnetometer reading.
//     - The angle is then converted to degrees and adjusted by -93 degrees and inverted (`degrees * -1`) to align the compass
//       orientation correctly (these adjustments might be device-specific or based on desired compass alignment).
// - UI Structure:
//     - `Column`: Arranges the compass UI elements vertically, centering them both horizontally and vertically within the available space.
//     - `RotationTransition`:  Rotates the compass needle based on the calculated `heading` value.
//         - `turns: AlwaysStoppedAnimation(heading! / 360)`:  Rotates the compass by a fraction of a full circle (360 degrees)
//           proportional to the `heading`. `AlwaysStoppedAnimation` is used for direct angle setting based on heading value.
//     - `Padding`: Adds padding around the compass visual elements.
//     - `Stack`: Used to layer the different parts of the compass design on top of each other.
//         - Compass Background: A `Container` with `BoxShape.circle` and grey background color to represent the compass base.
//         - North Indicator: A red `Icon(Icons.navigation_rounded)` positioned at the top of the stack and rotated by 0 degrees (pointing north).
//         - South Indicator: A white `Icon(Icons.navigation_rounded)` positioned at the bottom of the stack and rotated by 180 degrees (math.pi radians, pointing south).
//         - Circular Border: A `Container` with `BoxShape.circle`, white border, and no background color, creating a circular outline for the compass.
//
// Dependencies:
// - `sensors_plus` package:  Needed to access device magnetometer sensor data.
// - `dart:math` library: Used for mathematical functions like `atan2` and `pi` for heading calculation and rotation.
//
// Notes:
// - Compass accuracy and availability depend on the device's hardware and sensor availability.
// - Calibration of the magnetometer sensor might be required for optimal accuracy.
// - The heading calculation and adjustments (like -93 degrees and inversion) might need fine-tuning based on the specific device
//   and desired compass orientation.
// - Error handling for scenarios where magnetometer sensor is not available or readings are unreliable is not explicitly implemented
//   in this basic widget and might be considered for production use.

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
