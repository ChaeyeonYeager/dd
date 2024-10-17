import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeScreen extends StatelessWidget {
  final User user;

  WelcomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('환영합니다!'),
      ),
      body: Center(
        child: Text(
          '환영합니다, ${user.displayName}님!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
