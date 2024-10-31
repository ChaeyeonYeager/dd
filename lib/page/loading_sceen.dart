import 'package:flutter/material.dart';
import 'package:my_app/auth_page.dart';
import 'calendar_page.dart';
import 'diary_page.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/loading.jpg',
            ),
          ),
          Align(
            alignment: const FractionalOffset(0.5, 0.45),
            child: SizedBox(
              width: 150, // 스피너의 크기
              height: 150,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                strokeWidth: 8.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
