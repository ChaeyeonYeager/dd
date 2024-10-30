import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'my_button.dart';
import 'my_textfield.dart';
import 'square_title.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart'; // 등록 페이지 임포트
import 'login_or_register_page.dart'; // 등록 페이지 임포트

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final paswswordController = TextEditingController();
  final confrimpaswswordController = TextEditingController();

  // sign user up method
  void signUserUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    // try creating the user
    try {
      // check if password is confirmed
      if (paswswordController.text == confrimpaswswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: paswswordController.text,
        );
      } else {
        // show error message, passwords don't match
        showErrorMessage("Passwords don't match!");
      }
      // pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      // show error message
      showErrorMessage(e.code);
    }
  }

  // error message to user
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6200EE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // 로고
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/logo.jpg'),
                ),

                const SizedBox(height: 50),

                // let's create an account for you
                Text(
                  'Let\'s create an account for you!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // 이메일 입력 필드
                MyTextField(
                  controller: emailController,
                  hintText: 'E-Mail',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // 패스워드 입력 필드
                MyTextField(
                  controller: paswswordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // 패스워드 확인 입력 필드
                MyTextField(
                  controller: confrimpaswswordController,
                  hintText: 'Password Confirm',
                  obscureText: true,
                ),

                // sign up button
                My_Button(
                  text: "Sign up",
                  onTap: signUserUp,
                ),

                const SizedBox(height: 20),

                // back button (로고 아이콘으로 변경)
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // LoginOrRegisterPage로 돌아가기
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginOrRegisterPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
