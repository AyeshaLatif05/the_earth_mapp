import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_earth_map/onboarding_screen.dart';
import '../providers/language_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  void initState() {
    super.initState();

    // Start fetching language preference in parallel with the splash timer
    Future.wait([
      ref.read(languageProvider.notifier).init().timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () {
          debugPrint("Language initialization timed out, defaulting.");
        },
      ),
      Future.delayed(const Duration(seconds: 2)),
    ]).then((_) {
      if (mounted) {
        // Navigate to next screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1D8177),
      body: Center(
        child: Image.asset(
          'assets/iconmap.png',
          scale: 4,
        ),
      ),
    );
  }
}

