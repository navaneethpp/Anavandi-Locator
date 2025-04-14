import 'package:flutter/material.dart';

class OnBusConfirmationDialog extends StatelessWidget {
  final Function(bool) onConfirmation;

  const OnBusConfirmationDialog({super.key, required this.onConfirmation});

  Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you on the bus?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to hide your location on the map?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmation(true); // User is on the bus, hide location
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmation(false); // User is not on the bus, show location
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget doesn't directly build anything in the widget tree
    // as it's designed to show a dialog.
    return const SizedBox.shrink();
  }
}
