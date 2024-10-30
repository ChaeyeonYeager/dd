import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/page/calendar_page.dart';
import 'login_or_register_page.dart';
import 'page/loading_sceen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen(); // 로딩 상태 표시
          }
          // 로그인된 상태라면 HomePage로 이동
          if (snapshot.hasData) {
            Future.microtask(() {
              // 사용자가 로그인된 경우 CalendarPage로 바로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage()),
              );
            });
            // CalendarPage로 전환되는 동안 빈 Container를 반환 (페이지가 보이지 않도록)
            return LoadingScreen(); // 캘린더로 이동 중 로딩 화면 표시
          }
          // 로그인이 안 된 상태라면 로그인/회원가입 페이지로 이동
          else {
            return LoginOrRegisterPage(); // 로그인 페이지로 이동
          }
        },
      ),
    );
  }
}
