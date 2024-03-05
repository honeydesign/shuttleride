import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shuttleride/authentication/login_screen.dart';
import 'package:shuttleride/splash_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin
 {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen())
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF007AFF),
        ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                "assets/images/logowhite.jpg"
            ),
          ],
          ),

        ),

    );
  }
}
