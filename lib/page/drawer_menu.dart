import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/login_or_register_page.dart';

class DrawerMenu extends StatefulWidget {
  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  String? displayName;
  String? email;

  @override
  void initState() {
    super.initState();
    // Firebase에서 현재 사용자 정보 가져오기
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      email = user?.email;
      displayName = email?.split('@').first ?? 'User';
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginOrRegisterPage()), // 수정
    );
  }

  void _editDisplayName() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController nameController =
            TextEditingController(text: displayName);
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  displayName = nameController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF6200EE),
            ),
            accountName: Text(
              displayName ?? 'User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              email ?? 'No email',
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
                onTap: _editDisplayName,
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            title: const Text('LOG OUT', style: TextStyle(color: Colors.grey)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
