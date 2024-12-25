import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final void Function()? onTap;
  final String text;

  const MyButton({super.key, this.onTap, required this.text});

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.35; // 35% от ширины экрана
    final buttonHeight = 40.0; // Увеличена высота

    return Center(
      child: MouseRegion(
        onEnter: (event) => setState(() => isHovered = true),
        onExit: (event) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: buttonWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              color: isHovered ? const Color(0xFFC84B31) : const Color(0xFF2D4263), // Цвет кнопки при наведении и по умолчанию
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                if (isHovered)
                  BoxShadow(
                    color: const Color(0xFFC84B31).withOpacity(0.8), // Эффект свечения при наведении
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                widget.text,
                style: TextStyle(
                  color: const Color(0xFFECDBBA), // Цвет текста всегда такой
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'RussoOne-Regular',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}