import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart'; // Import the package

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.hexagonDots(
        // Choose your preferred animation here
        color: Colors.blue, // Customize the color
        size: 50, // Customize the size
      ),
    );
  }
}
