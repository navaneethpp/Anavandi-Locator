import 'package:flutter/material.dart';

class IconButtonWidget extends StatelessWidget {
  final IconData iconData;
  final VoidCallback? onPressed;

  const IconButtonWidget({super.key, required this.iconData, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(iconData), onPressed: onPressed);
  }
}
