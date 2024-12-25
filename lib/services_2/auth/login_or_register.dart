import 'package:flutter/material.dart';
import '/pages/login_page_2.dart';
import '/pages/register_page_2.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLoginPage ? LoginPage2(onTap: togglePages) : RegisterPage2(onTap: togglePages);
  }
}