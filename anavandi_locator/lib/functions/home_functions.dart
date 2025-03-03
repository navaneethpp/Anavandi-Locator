import 'package:flutter/material.dart';

// Swap function now takes parameters to work independently
void swapTextFields({
  required String currentStartingPoint,
  required String currentDestination,
  required TextEditingController startController,
  required TextEditingController destController,
  required void Function(void Function())
  setStateCallback, // Callback for setState
  required Function(String)
  updateStartingPoint, // Callback to update _startingPoint
  required Function(String)
  updateDestination, // Callback to update _destination
}) {
  String temp = currentStartingPoint;
  currentStartingPoint = currentDestination;
  currentDestination = temp;

  startController.text = currentStartingPoint;
  destController.text = currentDestination;

  setStateCallback(() {
    updateStartingPoint(currentStartingPoint); // Update state in Home widget
    updateDestination(currentDestination); // Update state in Home widget
  });
}
