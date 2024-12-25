import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> with SingleTickerProviderStateMixin {
  late FocusNode focusNode;
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textFieldWidth = screenWidth * 0.35; // 35% от ширины экрана

    return SizedBox(
      width: textFieldWidth,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return CustomPaint(
                painter: BorderGradientPainter(
                  animationValue: animation.value,
                  isFocused: focusNode.hasFocus,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  child: child,
                ),
              );
            },
            child: TextField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              focusNode: focusNode,
              cursorColor: const Color(0xFFC84B31),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: const Color(0xFFECDBBA),
                filled: true,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: focusNode.hasFocus ? const Color(0xFFC84B31) : const Color(0xFF2D4263),
                  fontFamily: 'Tektur',
                ),
              ),
              style: TextStyle(
                color: focusNode.hasFocus ? const Color(0xFFC84B31) : (widget.controller.text.isNotEmpty ? const Color(0xFF2D4263) : const Color(0xFFECDBBA)),
                fontFamily: 'Tektur',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BorderGradientPainter extends CustomPainter {
  final double animationValue;
  final bool isFocused;

  BorderGradientPainter({
    required this.animationValue,
    required this.isFocused,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (isFocused) {
      final gradient = LinearGradient(
        colors: [Color(0xFFC84B31), Color(0xFFECDBBA)],
        stops: [animationValue, animationValue + 0.1],
      );
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      paint.shader = gradient.createShader(rect);
    } else {
      paint.color = const Color(0xFF2D4263);
    }

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(10)));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
