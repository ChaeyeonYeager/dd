import 'package:flutter/material.dart';

class MoodDetailPage extends StatelessWidget {
  final String label;
  final String imagePath;

  MoodDetailPage({required this.label, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$label Mood"),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              label,
              style: TextStyle(fontSize: 32, color: Colors.purple, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
