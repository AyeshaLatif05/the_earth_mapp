// lib/screens/information_tools_screen.dart

import 'package:flutter/material.dart';

class InformationToolsScreen extends StatelessWidget {
  const InformationToolsScreen({super.key});

  static const List<_ToolItem> _tools = [
    _ToolItem(
      title: 'Live Sensor',
      subtitle: 'Real-time data from your device sensors',
      bgColor: Color(0xFFFFF0E6),
      iconAsset: 'assets/images/ic_sensor.png',
    ),
    _ToolItem(
      title: 'Oxygen Level',
      subtitle: 'Monitor oxygen level and air quality',
      bgColor: Color(0xFFEDEAF5),
      iconAsset: 'assets/images/ic_oxygen.png',
    ),
    _ToolItem(
      title: 'Speedometer',
      subtitle: 'Track your current speed in real time',
      bgColor: Color(0xFFE8F5E9),
      iconAsset: 'assets/images/ic_speedometer.png',
    ),
    _ToolItem(
      title: 'Compass',
      subtitle: 'Find your direction anywhere on Earth',
      bgColor: Color(0xFFE3F2FD),
      iconAsset: 'assets/images/ic_compass.png',
    ),
    _ToolItem(
      title: 'Live Weather',
      subtitle: 'Check current weather updates anywhere',
      bgColor: Color(0xFFE8F0FB),
      iconAsset: 'assets/images/ic_weather.png',
    ),
    _ToolItem(
      title: 'Countries Info',
      subtitle: 'Explore key info about countries worldwide',
      bgColor: Color(0xFFFCE8E8),
      iconAsset: 'assets/images/ic_countries.png',
    ),
    _ToolItem(
      title: 'Level Meter',
      subtitle: 'Check surface level and tilt accurately',
      bgColor: Color(0xFFFFF8EC),
      iconAsset: 'assets/images/ic_level_meter.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.black, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Information Tools',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Grid ────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: _tools.length,
                  itemBuilder: (context, index) {
                    return _ToolCard(tool: _tools[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tool Card ──────────────────────────────────────────────────────────────────
class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});

  final _ToolItem tool;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (tool.title == 'Oxygen Level') {
          Navigator.pushNamed(context, '/oxygen_level');
        } else if (tool.title == 'Level Meter') {
          Navigator.pushNamed(context, '/level_meter');
        } else if (tool.title == 'Countries Info') {
          Navigator.pushNamed(context, '/countries_info');
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${tool.title}" feature is coming soon!'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        decoration: BoxDecoration(
          color: tool.bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon — top center like screenshot
            Center(
              child: Image.asset(
                tool.iconAsset,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image_outlined,
                      color: Colors.grey, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              tool.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
                height: 1.2,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              tool.subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _ToolItem {
  final String title;
  final String subtitle;
  final Color bgColor;
  final String iconAsset;

  const _ToolItem({
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconAsset,
  });
}