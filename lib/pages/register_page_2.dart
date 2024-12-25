import 'package:flutter/material.dart';
import '/components/my_button.dart';
import '/components/my_text_field.dart';
import '/services_2/auth/auth_service_2.dart';
import 'package:provider/provider.dart';
import '/painters/snowflake_painter.dart'; // Импортируем кастомный painter для снежинок

class RegisterPage2 extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage2({super.key, this.onTap});

  @override
  State<RegisterPage2> createState() => _RegisterPage2State();
}

class _RegisterPage2State extends State<RegisterPage2> with SingleTickerProviderStateMixin {
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _animation;

  // Курсор
  Offset cursorPosition = Offset.zero;

  // Sign up
  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    // Get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10), // Увеличиваем продолжительность анимации
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final cardWidth = isMobile ? screenWidth * 0.9 : screenWidth * 0.45; // Увеличиваем ширину карточки на мобильных устройствах

    return Scaffold(
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            cursorPosition = event.position; // Отслеживаем положение курсора
          });
        },
        child: Stack(
          children: [
            // Background with moving gradient
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment(
                        cursorPosition.dx / screenWidth,
                        cursorPosition.dy / MediaQuery.of(context).size.height,
                      ),
                      colors: [Color(0xFF191919), Color(0xFF56423D)], // Градиент фона
                    ),
                  ),
                );
              },
            ),
            // Snowflakes
            CustomPaint(
              size: Size(double.infinity, double.infinity),
              painter: SnowflakePainter(_animation, cursorPosition),
            ),
            // Card
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: SizedBox(
                  width: cardWidth,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Color(0xFFECDBBA), // Цвет карточки
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),

                          // Logo replacement with text
                          Text(
                            'MANgo100',
                            style: TextStyle(
                              fontSize: 28, // Увеличенный размер текста
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC84B31), // Цвет заголовка
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Create message
                          Text(
                            'Let`s create an account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF191919), // Цвет текста
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Email
                          SizedBox(
                            width: isMobile ? cardWidth * 0.9 : null,
                            child: MyTextField(
                              controller: emailController,
                              hintText: 'Email',
                              obscureText: false,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Password
                          SizedBox(
                            width: isMobile ? cardWidth * 0.9 : null,
                            child: MyTextField(
                              controller: passwordController,
                              hintText: 'Password',
                              obscureText: true,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Confirm password
                          SizedBox(
                            width: isMobile ? cardWidth * 0.9 : null,
                            child: MyTextField(
                              controller: confirmPasswordController,
                              hintText: 'Confirm password',
                              obscureText: true,
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Button
                          SizedBox(
                            width: isMobile ? cardWidth * 0.9 : null,
                            child: MyButton(onTap: signUp, text: 'Sign Up'),
                          ),

                          const SizedBox(height: 20),

                          // Register
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already a member?',
                                style: TextStyle(
                                  color: Color.fromARGB(86, 86, 66, 61), // Цвет текста
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: widget.onTap,
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(100, 86, 66, 61), // Цвет текста
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
