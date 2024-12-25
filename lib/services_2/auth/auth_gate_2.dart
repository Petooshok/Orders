import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:menu/main.dart';
import '/pages/chats_1.dart';
import '/services_2/auth/login_or_register.dart';

class AuthGate2 extends StatelessWidget {
  const AuthGate2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Если пользователь аутентифицирован, показываем главную страницу
          if (snapshot.hasData) {
            return const MainPage(initialIndex: 0);
          }

          // Если есть ошибка, показываем сообщение об ошибке
          if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка: ${snapshot.error}'),
            );
          }

          // Если состояние не определено, показываем индикатор загрузки
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Если пользователь не аутентифицирован, перенаправляем на страницу входа
          return const LoginOrRegister();
        },
      ),
    );
  }
}