import 'package:flutter/material.dart';
import 'dart:math';

class SnowflakePainter extends CustomPainter {
  final Animation<double> animation;
  final Offset cursorPosition;

  SnowflakePainter(this.animation, this.cursorPosition);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final random = Random();
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 2;
      final opacity = (random.nextDouble() * 0.5 + 0.2).clamp(0.0, 1.0);

      // Анимация снежинок по направлению курсора
      final snowflakeY = y + (cursorPosition.dy / size.height * animation.value * size.height * 0.5);
      paint.color = Colors.white.withOpacity(opacity);

      canvas.drawCircle(Offset(x, snowflakeY % size.height), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}