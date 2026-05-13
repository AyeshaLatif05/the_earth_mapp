// lib/screens/home_screen.dart

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E2A),
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──
            _buildAppBar(),

            // ── Scrollable Content ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Globe Hero ──
                    _buildGlobeHero(),

                    // ── White content area ──
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Home Location Card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildHomeLocationCard(),
                          ),
                          const SizedBox(height: 12),

                          // Live Earth Map Banner
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildLiveEarthBanner(),
                          ),
                          const SizedBox(height: 24),

                          // Map Tools Section
                          _buildSectionHeader('Map Tools', onTap: () {}),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _ToolCard(
                                    title: '3D Earth Map',
                                    subtitle: 'Explore the planet using live satellite data',
                                    bgColor: const Color(0xFFDFF0FB),
                                    iconAsset: 'assets/images/ic_3d_map.png',
                                    onTap: () {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ToolCard(
                                    title: 'My Location',
                                    subtitle: 'Find your current position on the map',
                                    bgColor: const Color(0xFFFDE8E8),
                                    iconAsset: 'assets/images/ic_my_location.png',
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Calculation Tools Section
                          _buildSectionHeader('Calculation Tools', onTap: () {}),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _ToolCard(
                                    title: 'Check Altitude',
                                    subtitle: 'Explore Earth in an interactive 3D view',
                                    bgColor: const Color(0xFFEDEAF5),
                                    iconAsset: 'assets/images/ic_altitude.png',
                                    onTap: () {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ToolCard(
                                    title: 'Find Traffic',
                                    subtitle: 'See real-time traffic updates on your route',
                                    bgColor: const Color(0xFFFFF8E1),
                                    iconAsset: 'assets/images/ic_traffic.png',
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Information Tools Section
                          _buildSectionHeader('Information Tools', onTap: () {}),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _ToolCard(
                                    title: 'Live Sensor',
                                    subtitle: 'Real-time data from your device sensors',
                                    bgColor: const Color(0xFFFFF0E6),
                                    iconAsset: 'assets/images/ic_sensor.png',
                                    onTap: () {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ToolCard(
                                    title: 'Oxygen Level',
                                    subtitle: 'Monitor oxygen level and air quality',
                                    bgColor: const Color(0xFFE8EDF8),
                                    iconAsset: 'assets/images/ic_oxygen.png',
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
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

  // ── AppBar ──
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Colors.white, size: 26),
          const SizedBox(width: 14),
          const Text(
            'Explore Earth',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Globe Hero ──
  Widget _buildGlobeHero() {
    return SizedBox(
      height: 180,
      child: Center(
        child: Image.asset(
          'assets/images/globe_hero.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.public,
            size: 120,
            color: Color(0xFF4A6CF7),
          ),
        ),
      ),
    );
  }

  // ── Home Location Card ──
  Widget _buildHomeLocationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFFE53935), size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Add Home Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, color: Color(0xFF6B7280), size: 20),
        ],
      ),
    );
  }

  // ── Live Earth Banner ──
  Widget _buildLiveEarthBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A7A68),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Earth Map',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Explore Live Cameras and ...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/ic_cctv.png',
            width: 52,
            height: 52,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.videocam_outlined,
              color: Colors.white70,
              size: 44,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ──
  Widget _buildSectionHeader(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: const Icon(
              Icons.chevron_right,
              color: Color(0xFF6B7280),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Tool Card ──
class _ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color bgColor;
  final String iconAsset;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconAsset,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Image.asset(
              iconAsset,
              width: 48,
              height: 48,
              errorBuilder: (_, __, ___) => Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image_outlined,
                    color: Colors.grey, size: 24),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
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
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}