import 'package:flutter/material.dart';
import 'package:my_app/auth_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> images = [
    'assets/splash/splash_0.png',
    'assets/splash/splash_1.png',
    'assets/splash/splash_2.png',
    'assets/splash/splash_3.png',
    'assets/splash/splash_4.png',
    'assets/splash/splash_5.png',
    'assets/splash/splash_6.png',
    'assets/splash/splash_7.png',
    'assets/splash/splash_8.png'
  ];

  // 각 이미지를 보여줄 수 있는 상태 리스트
  List<bool> _visibleImages = List.generate(9, (index) => false);

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    for (int i = 0; i < images.length; i++) {
      Future.delayed(Duration(seconds: 1) * i, () {
        setState(() {
          _visibleImages[i] = true; // 현재 인덱스의 이미지를 보이게 설정
        });

        // 마지막 이미지가 보인 후, auth_page로 이동
        if (i == images.length - 1) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => AuthPage()));
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: images.asMap().entries.map((entry) {
          int index = entry.key;
          String imagePath = entry.value;
          return AnimatedOpacity(
            opacity: _visibleImages[index] ? 1.0 : 0.0, // 보일 때는 1.0, 아닐 때는 0.0
            duration: Duration(milliseconds: 500), // 애니메이션 시간
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          );
        }).toList(),
      ),
    );
  }
}
