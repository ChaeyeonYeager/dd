import 'package:flutter/material.dart';
import './calendar_page.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 실제 로딩 작업을 수행하고 완료되면 페이지를 이동
    _loadDataAndNavigate(context);

    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center, // 중앙 정렬
          children: [
            // 배경 로딩 이미지
            Image.asset(
              'assets/loading.jpg', // 배경 로딩 이미지 경로
              fit: BoxFit.cover,
            ),
            // 원형 로딩 스피너
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                strokeWidth: 8.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 데이터 로딩과 페이지 이동을 처리하는 비동기 함수
  Future<void> _loadDataAndNavigate(BuildContext context) async {
    // 여기서 실제 로딩 작업을 수행합니다. 예를 들어 API 호출이나 데이터베이스 쿼리 등.
    await Future.delayed(Duration(seconds: 4)); // 예시로 4초 대기. 실제 작업으로 대체.

    // 로딩 작업이 끝난 후 캘린더 페이지로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CalendarPage()),
    );
  }
}
