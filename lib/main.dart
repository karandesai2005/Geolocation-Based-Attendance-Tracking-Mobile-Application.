import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'attendance_tracker.dart'; // Import AttendanceTracker
import 'login_screen.dart';
import 'register_screen.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AttendanceTracker attendanceTracker = AttendanceTracker(); // Create instance

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(), // Initial screen
      routes: {
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomePage(attendanceTracker: attendanceTracker), // Pass attendanceTracker instance
      },
    );
  }
}