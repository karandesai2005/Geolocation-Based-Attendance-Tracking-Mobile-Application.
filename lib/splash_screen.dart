import 'package:flutter/material.dart';
import 'package:flutter_animated_splash/flutter_animated_splash.dart';
import 'login_screen.dart'; // Replace with your login screen path

class MySplashScreen extends StatelessWidget {
  const MySplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplash(
      type: Transition.fade, // Replace with your logo image
      backgroundColor: const Color.fromARGB(255, 22, 48, 136), // Use backgroundColor for background color
      durationInSeconds: 3, // Splash screen duration in seconds
      navigator: LoginScreen(), // Choose your transition type (fade, size, slide)
      child: Image.asset("assets/my_logo.png"), // Navigate to the login screen after splash
    );
  }
}