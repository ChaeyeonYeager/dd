import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF6200EE), // 사이드바 헤더 배경색
            ),
            accountName: const Text(
              "SONG SAEM",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text(
              "ssongsams@naver.com",
              style: TextStyle(fontSize: 14),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 50,
                color: Color(0xFF6200EE),
              ),
            ),
            otherAccountsPictures: [
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const ListTile(
            leading: Icon(Icons.question_answer, color: Color(0xFF6200EE)),
            title: Text('Q&A'),
          ),
          const ListTile(
            leading: Icon(Icons.color_lens, color: Color(0xFF6200EE)),
            title: Text('Theme'),
          ),
          const ListTile(
            leading: Icon(Icons.question_answer, color: Color(0xFF6200EE)),
            title: Text('Q&A'),
          ),
          const ListTile(
            leading: Icon(Icons.color_lens, color: Color(0xFF6200EE)),
            title: Text('Theme'),
          ),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            title: const Text('LOG OUT', style: TextStyle(color: Colors.grey)),
            onTap: () {
              // 로그아웃 기능
            },
          ),
        ],
      ),
    );
  }
}
