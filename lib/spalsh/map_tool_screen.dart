// lib/screens/map_tools_screen.dart

import 'package:flutter/material.dart';

class MapToolsScreen extends StatelessWidget {
  const MapToolsScreen({super.key});

  static const List<_ToolItem> _tools = [
    _ToolItem(
      title: '3D Earth Map',
      subtitle: 'Explore the planet using live satellite data',
      bgColor: Color(0xFFDFF0FB),
      iconAsset: 'assets/terrain.png',
    ),
    _ToolItem(
      title: 'My Location',
      subtitle: 'Find your current position on the map',
      bgColor: Color(0xFFFDE8E8),
      iconAsset: 'assets/loc.png',
      iconColor: Color(0xFFE53935), // Red pin to match location pins
    ),
    _ToolItem(
      title: 'Street View',
      subtitle: 'Explore the planet using live satellite data',
      bgColor: Color(0xFFF0F0F0),
      iconAsset: 'assets/view.png',
    ),
    _ToolItem(
      title: '3D Globe',
      subtitle: 'Explore Earth in an interactive 3D view',
      bgColor: Color(0xFFEAF5EA),
      iconAsset: 'assets/icon earth map.png',
    ),
    _ToolItem(
      title: 'Meet in Middle',
      subtitle: 'Discover a midpoint between locations',
      bgColor: Color(0xFFFCECEC),
      iconAsset: 'assets/Frame.png',
    ),
    _ToolItem(
      title: 'Voice Navigation',
      subtitle: 'Let voice guide you on your route',
      bgColor: Color(0xFFFFFBE6),
      iconAsset: 'assets/Rotate.png',
    ),
    _ToolItem(
      title: 'Your Parking',
      subtitle: 'Stores your parking spot for quick access',
      bgColor: Color(0xFFFDE8E8),
      iconAsset: 'assets/parking 1.png',
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.black, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Map Tools',
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
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        decoration: BoxDecoration(
          color: tool.bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                tool.iconAsset,
                width: 64,
                height: 64,
                color: tool.iconColor,
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
  final Color? iconColor;

  const _ToolItem({
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconAsset,
    this.iconColor,
  });
}