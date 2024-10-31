import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/page/calendar_page.dart';
import 'login_or_register_page.dart';
import 'page/loading_sceen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 1초 후에 로딩 상태를 false로 변경
    Timer(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false; // 로딩 플래그 해제
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 연결 상태가 대기 중일 때는 로딩 화면 표시
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen();
          }

          // 로그인된 상태라면 CalendarPage로 이동
          if (snapshot.hasData) {
            // 사용자가 로그인된 경우
            if (_isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _isLoading = false; // 로딩 플래그 해제
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarPage()),
                );
              });
            }
            return LoadingScreen();
          }

          // 로그인이 안 된 상태라면 로그인/회원가입 페이지로 이동
          return LoginOrRegisterPage();
        },
      ),
    );
  }
}
