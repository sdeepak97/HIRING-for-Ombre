import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:streaming/model/auth_service.dart';
import 'dart:async';
import 'dart:developer';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:streaming/src/pages/callpage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ClientRole _role = ClientRole.Broadcaster;
  final ClientRole _role1 = ClientRole.Audience;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: const Text("Home page"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                AuthService().signOut();
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        // color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Hi ${FirebaseAuth.instance.currentUser!.displayName!}",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
           const  Text(
              "Welcome to Streaming Platfrom",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              padding: const EdgeInsets.all(10),
              color: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              onPressed: onjoin,
              child: const Text(
                'Go live',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            MaterialButton(
              padding: const EdgeInsets.all(10),
              color: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              onPressed: watchStream,
              child: const Text(
                'Watch Live Stream',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onjoin() async {
    await _handleCamerAndMic(Permission.camera);
    await _handleCamerAndMic(Permission.microphone);

    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => CallPage(role: _role)));

    // }
  }

  Future<void> watchStream() async {
    // await _handleCamerAndMic(Permission.camera);
    // await _handleCamerAndMic(Permission.microphone);
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CallPage(
                  role: _role1,
                )));
    // }
  }

  Future<void> _handleCamerAndMic(Permission permission) async {
    final status = await permission.request();
    log((status.toString()));
  }
}
