// lib/screens/information_tools_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/language_provider.dart';

class InformationToolsScreen extends ConsumerWidget {
  const InformationToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationProvider);

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
        title: Text(
          tr['information_tools'] ?? 'Information Tools',
          style: const TextStyle(
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
            _InfoToolCard(
              title: tr['live_sensor'] ?? 'Live Sensor',
              subtitle: tr['real_time_sensor_data'] ?? 'Real-time data from your device sensors',
              bgColor: const Color(0xFFFFF0E6), // Pastel orange
              iconAsset: 'assets/speed.png',
              onTap: () {
                Navigator.pushNamed(context, '/live_sensor');
              },
            ),
            _InfoToolCard(
              title: tr['oxygen_level'] ?? 'Oxygen Level',
              subtitle: tr['monitor_oxygen_quality'] ?? 'Monitor oxygen level and air quality',
              bgColor: const Color(0xFFE8EDF8), // Pastel blue/grey
              iconAsset: 'assets/windy.png',
              onTap: () {
                Navigator.pushNamed(context, '/oxygen_level');
              },
            ),
            _InfoToolCard(
              title: tr['speedometer'] ?? 'Speedometer',
              subtitle: tr['track_current_speed'] ?? 'Track your current speed in real time',
              bgColor: const Color(0xFFEBF8EA), // Pastel green
              iconAsset: 'assets/speed.png',
              onTap: () {
                Navigator.pushNamed(context, '/speedometer');
              },
            ),
            _InfoToolCard(
              title: tr['compass'] ?? 'Compass',
              subtitle: tr['find_direction_earth'] ?? 'Find your direction anywhere on Earth',
              bgColor: const Color(0xFFE3F2FD), // Pastel cyan
              iconAsset: 'assets/Rotate.png',
              onTap: () {
                Navigator.pushNamed(context, '/compass');
              },
            ),
            _InfoToolCard(
              title: tr['live_weather'] ?? 'Live Weather',
              subtitle: tr['check_weather_updates'] ?? 'Check current weather updates anywhere',
              bgColor: const Color(0xFFE8F4FD), // Pastel light blue
              iconAsset: 'assets/weath.png',
              onTap: () {
                Navigator.pushNamed(context, '/live_weather');
              },
            ),
            _InfoToolCard(
              title: tr['countries_info'] ?? 'Countries Info',
              subtitle: tr['explore_countries_worldwide'] ?? 'Explore key info about countries worldwide',
              bgColor: const Color(0xFFFFF1F0), // Pastel pink/coral
              iconAsset: 'assets/lang.png',
              onTap: () {
                Navigator.pushNamed(context, '/countries_info');
              },
            ),
            _InfoToolCard(
              title: tr['level_meter'] ?? 'Level Meter',
              subtitle: tr['check_surface_level'] ?? 'Check surface level and tilt accurately',
              bgColor: const Color(0xFFFEFBE8), // Pastel yellow/cream
              iconAsset: 'assets/level.png',
              onTap: () {
                Navigator.pushNamed(context, '/level_meter');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Info Tool Card Widget ──
class _InfoToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color bgColor;
  final String iconAsset;
  final VoidCallback onTap;

  const _InfoToolCard({
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
