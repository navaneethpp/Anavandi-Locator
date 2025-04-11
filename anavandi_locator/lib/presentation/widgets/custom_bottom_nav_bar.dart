import 'package:flutter/material.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onButtonPressed;
  final List<BarItem> barItems;
  final Color backgroundColor;
  final Color activeColor;
  final double bottomPadding; // Add a parameter for bottom padding

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onButtonPressed,
    required this.barItems,
    this.backgroundColor = Colors.transparent,
    this.activeColor = Colors.blue,
    this.bottomPadding = 16.0, // Default bottom padding of 16.0
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SlidingClippedNavBar(
        backgroundColor: backgroundColor,
        onButtonPressed: onButtonPressed,
        activeColor: activeColor,
        selectedIndex: selectedIndex,
        barItems: barItems,
      ),
    );
  }
}
