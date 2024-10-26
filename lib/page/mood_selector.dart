import 'package:flutter/material.dart';
import 'mood_detail_page.dart';

class MoodSelector extends StatefulWidget {
  @override
  _MoodSelectorState createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  final List<Map<String, dynamic>> moods = [
    {'label': 'SAD', 'imagePath': 'assets/sad.jpg'},
    {'label': 'ANGRY', 'imagePath': 'assets/angry.jpg'},
    {'label': 'CONFIDENCE', 'imagePath': 'assets/confidence.jpg'},
    {'label': 'EXCITED', 'imagePath': 'assets/excited.jpg'},
    {'label': 'ANXIETY', 'imagePath': 'assets/anxiety.jpg'},
    {'label': 'HAPPY', 'imagePath': 'assets/happy.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text("Today's MOOD"),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // 왼쪽 상단 메뉴 버튼 동작
            print("Menu button pressed");
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // 오른쪽 상단 설정 버튼 동작
              print("Settings button pressed");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's",
              style: TextStyle(fontSize: 28, color: Colors.purple),
            ),
            Text(
              "MOOD",
              style: TextStyle(fontSize: 36, color: Colors.purple, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  final mood = moods[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MoodDetailPage(
                            label: mood['label'] as String,
                            imagePath: mood['imagePath'] as String,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          mood['imagePath'] as String,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
