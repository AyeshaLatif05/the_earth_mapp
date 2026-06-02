// lib/screens/map_tools_screen.dart

import 'package:flutter/material.dart';

class MapToolsScreen extends StatelessWidget {
  const MapToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Map Tools',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.82, // Optimized ratio to prevent overflow and keep premium layout
          physics: const BouncingScrollPhysics(),
          children: [
            _MapToolCard(
              title: '3D Earth Map',
              subtitle: 'Explore the planet using live satellite data',
              bgColor: const Color(0xFFE6F4FF), // Pastel blue
              iconAsset: 'assets/terrain.png',
              onTap: () {
                Navigator.pushNamed(context, '/street_view');
              },
            ),
            _MapToolCard(
              title: 'My Location',
              subtitle: 'Find your current position on the map',
              bgColor: const Color(0xFFFFF1F0), // Pastel coral/red
              iconAsset: 'assets/loc.png',
              iconColor: const Color(0xFFE53935), // Red pin to match
              onTap: () {
                Navigator.pushNamed(context, '/street_view');
              },
            ),
            _MapToolCard(
              title: 'Street View',
              subtitle: 'Explore the planet using live satellite data',
              bgColor: const Color(0xFFF5F6FA), // Pastel grey
              iconAsset: 'assets/view.png',
              onTap: () {
                Navigator.pushNamed(context, '/street_view');
              },
            ),
            _MapToolCard(
              title: '3D Globe',
              subtitle: 'Explore Earth in an interactive 3D view',
              bgColor: const Color(0xFFEBF8EA), // Pastel green
              iconAsset: 'assets/icon earth map.png', // Large globe asset resized
              onTap: () {
                Navigator.pushNamed(context, '/asia');
              },
            ),
            _MapToolCard(
              title: 'Meet in Middle',
              subtitle: 'Discover a midpoint between locations',
              bgColor: const Color(0xFFFFF0E6), // Pastel orange/peach
              iconAsset: 'assets/Frame.png', // Custom icon fallback
              onTap: () {
                Navigator.pushNamed(context, '/meet_in_middle');
              },
            ),
            _MapToolCard(
              title: 'Voice Navigation',
              subtitle: 'Let voice guide you on your route',
              bgColor: const Color(0xFFFEFBE8), // Pastel yellow/cream
              iconAsset: 'assets/Rotate.png',
              onTap: () {
                Navigator.pushNamed(context, '/voice_navigation');
              },
            ),
            _MapToolCard(
              title: 'Your Parking',
              subtitle: 'Stores your parking spot for quick access',
              bgColor: const Color(0xFFFFF1F0), // Pastel red/coral
              iconAsset: 'assets/parking 1.png', // Custom parking icon
              onTap: () {
                Navigator.pushNamed(context, '/parking');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Map Tool Card Widget ──
class _MapToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color bgColor;
  final String iconAsset;
  final Color? iconColor;
  final VoidCallback onTap;

  const _MapToolCard({
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconAsset,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Align Icon to top right
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                iconAsset,
                width: 44,
                height: 44,
                color: iconColor,
                errorBuilder: (_, __, ___) => Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                    size: 22,
                  ),
                ),
              ),
            ),

            // Text content aligned to bottom start
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF6B7280),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
