import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/auth_page.dart';

// 전체적으로 수정

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextPage();
  }

  void _navigateToNextPage() {
    // 5초 후에 다음 페이지로 전환
    Future.delayed(Duration(seconds: 4, milliseconds: 810), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/splash.gif', // GIF 파일 경로
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
