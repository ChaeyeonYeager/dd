import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/login_or_register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerMenu extends StatefulWidget {
  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  String? displayName;
  String? email;
  String? uid;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    // Firebase에서 현재 사용자 정보 가져오기
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email;
      uid = user.uid;
    }

    // SharedPreferences에서 사용자별 이름 가져오기
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      displayName = prefs.getString('displayName_$uid') ??
          email?.split('@').first ??
          'User';
    });
  }

  Future<void> _saveDisplayName(String name) async {
    // SharedPreferences에 사용자별 이름 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName_$uid', name);
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
              onPressed: () async {
                String newName = nameController.text;

                // 로컬 상태와 SharedPreferences에 이름 저장
                setState(() {
                  displayName = newName;
                });
                await _saveDisplayName(newName);

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
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
