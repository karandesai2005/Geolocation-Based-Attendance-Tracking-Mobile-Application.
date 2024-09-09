import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'attendance_tracker.dart'; // Import AttendanceTracker
import 'login_screen.dart';
import 'register_screen.dart';
import 'home.dart';
import 'splash_screen.dart'; // Import the splash screen widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AttendanceTracker attendanceTracker = AttendanceTracker();

  MyApp({super.key}); // Create instance

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MySplashScreen(), // Initial route is the splash screen
      routes: {
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomePage(attendanceTracker: attendanceTracker), // Pass attendanceTracker instance
      },
    );
  }
}