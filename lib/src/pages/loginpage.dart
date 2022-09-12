import 'package:flutter/material.dart';
import 'package:streaming/model/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: const Text("Google Login"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        width: size.width,
        height: size.height,
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: size.height * 0.2,
            bottom: size.height * 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Welcome to Streaming platform \nSign in with  Google",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            GestureDetector(
                onTap: () {
                  AuthService().signInWithGoogle();
                },
                child: Card(
                  elevation: 12,
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Image.asset(
                      "assets/images/gmail.png",
                      width: 80,
                      height: 80,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
