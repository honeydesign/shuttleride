import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:shuttleride/authentication/login_screen.dart';
// import 'package:shuttleride/authentication/signup_screen.dart';
import 'package:shuttleride/splash_screen.dart';


Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission)
  {
    if(valueOfPermission)
    {
      Permission.locationWhenInUse.request();
    }
  });


  runApp(const MyApp());
}



class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF007AFF)),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

