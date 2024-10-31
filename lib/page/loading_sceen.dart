import 'package:flutter/material.dart';
import 'package:my_app/auth_page.dart';
import 'calendar_page.dart';
import 'diary_page.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final spinnerSize = screenHeight * 0.2; // 전체 높이의 20%로 설정

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/loading.jpg',
            ),
          ),
          Align(
            alignment: const FractionalOffset(0.5, 0.46),
            child: SizedBox(
              width: spinnerSize,
              height: spinnerSize,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                strokeWidth: 7.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
