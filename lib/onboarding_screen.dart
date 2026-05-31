import 'package:flutter/material.dart';
import 'package:live_earth_map/meet_in_middle_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Asymmetric Image Grid ──────────────────────────
            SizedBox(
              height: screenH * 0.54,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT COLUMN
                  Expanded(
                    flex: 33,
                    child: Column(
                      children: [
                        // Compass — tall (top, no top-left radius since edge)
                        Expanded(
                          flex: 56,
                          child: _GridImage(
                            imagePath: 'assets/clock.png',
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Traffic map
                        Expanded(
                          flex: 44,
                          child: _GridImage(
                            imagePath: 'assets/map.png',
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 4),

                  // CENTER COLUMN — floats down 55px
                  Expanded(
                    flex: 34,
                    child: Column(
                      children: [
                        const SizedBox(height: 55),
                        Expanded(
                          flex: 46,
                          child: _GridImage(
                            imagePath: 'assets/cross.png',
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          flex: 54,
                          child: _GridImage(
                            imagePath: 'assets/9 mint.png',
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 4),

                  // RIGHT COLUMN
                  Expanded(
                    flex: 33,
                    child: Column(
                      children: [
                        // AR / Navigate
                        Expanded(
                          flex: 46,
                          child: _GridImage(
                            imagePath: 'assets/newyork.png',
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Weather thermometer
                        Expanded(
                          flex: 54,
                          child: _GridImage(
                            imagePath: 'assets/map 2.png',
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom: Title + Subtitle + Button ─────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 20, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text block
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Navigate the World Smarter',
                          style: TextStyle(
                            fontSize: 26,           // matched to screenshot
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Discover maps, live data, and smart tools to understand the world around you.',
                          style: TextStyle(
                            fontSize: 16,
                             fontWeight: FontWeight.w500,  
                                     // matched to screenshot
                            color: Color(0xFF444444),
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),

                    // Button — pinned to bottom
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        style: ElevatedButton.styleFrom(
                          // Exact color from screenshot — darker teal
                          backgroundColor: const Color(0xFF00695C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Let's Get Started",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Image tile ───────────────────────────────────────────────────────────────
class _GridImage extends StatelessWidget {
  const _GridImage({
    required this.imagePath,
    required this.borderRadius,
  });

  final String imagePath;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFE0F2F1),
          child: const Icon(
            Icons.image_outlined,
            color: Color(0xFF00695C),
            size: 28,
          ),
        ),
      ),
    );
  }
}