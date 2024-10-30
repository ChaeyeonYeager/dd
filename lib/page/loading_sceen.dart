import 'package:flutter/material.dart';
import 'package:my_app/auth_page.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 실제 로딩 작업을 수행하고 완료되면 페이지를 이동

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            FittedBox(
              fit: BoxFit.contain,
              child: Container(
                child: Image.asset(
                  'assets/loading.jpg',
                ),
              ),
            ),

            // 고정 위치의 로딩 스피너
            Positioned(
              right:
                  MediaQuery.of(context).size.width * 0.27, // 화면 너비에 비례하여 위치 설정
              top: MediaQuery.of(context).size.height *
                  0.25, // 화면 높이에 비례하여 위치 설정
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
      ),
    );
  }
}

void showLoadingScreen(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingScreen());
}

void hideLoadingScreen(BuildContext context) {
  Navigator.pop(context);
}
