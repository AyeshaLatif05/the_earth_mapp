import 'dart:async';
import 'package:flutter/material.dart';
import 'package:live_earth_map/home_screen.dart';
import 'package:live_earth_map/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 8), () {
      // Navigate to next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1D8177),
      body: Center(
        child: Image.asset(
          'assets/iconmap.png',
          scale :4,
        ),
      ),
    );
  }
}

