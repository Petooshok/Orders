import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isRight;

  const ChatBubble({super.key, required this.message, required this.isRight});

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * 0.167; // Одна шестая от ширины экрана
    final color = widget.isRight ? const Color(0xFFC84B31) : const Color(0xFF2D4263);
    final glowColor = widget.isRight ? const Color(0xFFC84B31) : const Color(0xFF2D4263);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          alignment: widget.isRight ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color,
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(animation.value),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Wrap(
            children: [
              Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFECDBBA),
                  fontFamily: 'Tektur',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
