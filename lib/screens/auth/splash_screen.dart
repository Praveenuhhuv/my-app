import 'package:flutter/material.dart';
import 'package:pbc/screens/auth/login_screen.dart';
import 'package:pbc/screens/home_screen.dart';
import 'dart:developer' as devLog;
import '../../api/apis.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (APIs.auth.currentUser != null) {
        devLog.log('\nUser:  ${APIs.auth.currentUser}');

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
      //nav to home
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('welcome to PicBlockChain'),

        //floating button
      ),
      body: Stack(children: [
        //logo

        Positioned(
          top: mq.height * .15,
          right: mq.width * .25,
          width: mq.width * .5,
          child: Image.asset('images/icon.png'),
        ),
        Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            height: mq.height * .07,
            child: const Text('MADE BY TEAM 1',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.black87, letterSpacing: .5))),
      ]),
    );
  }
}
