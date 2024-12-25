import 'package:flutter/material.dart';
import '../painters/snowflake_painter.dart';

class SnowflakeAnimation extends StatefulWidget {
  @override
  _SnowflakeAnimationState createState() => _SnowflakeAnimationState();
}

class _SnowflakeAnimationState extends State<SnowflakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Offset cursorPosition = Offset.zero; // Положение курсора

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10), // Увеличиваем продолжительность анимации
      vsync: this,
    )..repeat();
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          cursorPosition = event.position; // Отслеживаем положение курсора
        });
      },
      child: CustomPaint(
        painter: SnowflakePainter(_animation, cursorPosition),
        child: Container(),
      ),
    );
  }
}