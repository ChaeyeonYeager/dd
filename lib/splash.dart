import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/auth_page.dart';

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
    // 4.81초 후에 다음 페이지로 전환
    Future.delayed(Duration(seconds: 4, milliseconds: 810), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 사이즈 정보를 가져오기 위해 MediaQuery 사용
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/splash.gif', // GIF 파일 경로
          width: screenSize.width, // 화면 너비에 맞게 설정
          height: screenSize.height, // 화면 높이에 맞게 설정
          fit: BoxFit.cover,
          //fit: BoxFit.contain, // 비율 유지하며 화면에 맞게 조절
        ),
      ),
    );
  }
}