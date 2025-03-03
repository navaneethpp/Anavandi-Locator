// lib/hexagon_painter.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math';

class HexagonPainter extends CustomPainter {
  final String text;
  final double radius;
  final Color hexagonColor; // Background color of the hexagon
  final Color textColor; // Text color inside the hexagon

  HexagonPainter({required this.text, this.radius = 30.0})
    : hexagonColor = _getHexagonColorForText(text),
      textColor = _getTextColorForText(text);

  static Color _getHexagonColorForText(String text) {
    if (text == 'Minnal') {
      return Colors.white; // White background for Minnal
    } else if (text == 'Express') {
      return const Color(
        0xFF1B5E20,
      ); // Dark Green for Express (Hex code 1B5E20)
    } else if (text == 'SF') {
      return Colors.red; // Red for SF
    } else if (text == 'FP') {
      return Colors.red; // Red for FP
    } else if (text == 'Ordinary') {
      return const Color(
        0xFF81D4FA,
      ); // Light Blue for Ordinary (Hex code 81D4FA)
    } else {
      return Colors.grey; // Default background color
    }
  }

  static Color _getTextColorForText(String text) {
    if (text == 'Minnal') {
      return Colors.black; // Black text for Minnal
    } else if (text == 'Express') {
      return Colors.white; // White text for Express
    } else if (text == 'SF') {
      return Colors.white; // White text for SF
    } else if (text == 'FP') {
      return Colors.white; // White text for FP
    } else if (text == 'Ordinary') {
      return Colors.black; // Black text for Ordinary
    } else {
      return Colors
          .white; // Default text color (white to contrast with grey bg)
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color =
              hexagonColor // Use hexagonColor for background
          ..style = PaintingStyle.fill;

    final path = ui.Path();
    final center = size.center(Offset.zero);
    final hexagonRadius = radius;

    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 2;
      final x = center.dx + hexagonRadius * cos(angle);
      final y = center.dy + hexagonRadius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
      (oldDelegate is HexagonPainter &&
          (oldDelegate.hexagonColor != hexagonColor ||
              oldDelegate.textColor != textColor)) ||
      false;
}
