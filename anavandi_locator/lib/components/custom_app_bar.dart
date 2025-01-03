// custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:anavandi_locator/constants/images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Add a title if needed

  const CustomAppBar({super.key, this.title = ""});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Image.asset(
            AppImages.appBarIcon,
            width: AppImageWidth.appBarIconWidth,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
