import 'package:flutter/material.dart';
import 'auth_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key}); // const 생성자 추가

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    });

    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          'lib/images/splash.jpeg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
