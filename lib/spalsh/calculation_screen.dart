// lib/screens/calculation_tools_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/travel_provider.dart';

class CalculationToolsScreen extends StatelessWidget {
  const CalculationToolsScreen({super.key});

  static const List<_ToolItem> _tools = [
    _ToolItem(
      title: 'Check Altitude',
      subtitle: 'Explore Earth in an interactive 3D view',
      bgColor: Color(0xFFEDEAF5),
      iconAsset: 'assets/level.png',
    ),
    _ToolItem(
      title: 'Find Traffic',
      subtitle: 'See real-time traffic updates on your route',
      bgColor: Color(0xFFFFF8E1),
      iconAsset: 'assets/dir.png',
    ),
    _ToolItem(
      title: 'GPS Camera',
      subtitle: 'Save photos with exact location info',
      bgColor: Color(0xFFE3F2FD),
      iconAsset: 'assets/cam.png',
    ),
    _ToolItem(
      title: 'Find Distance',
      subtitle: 'Shows distance between locations',
      bgColor: Color(0xFFE8F0FB),
      iconAsset: 'assets/distance.png',
    ),
    _ToolItem(
      title: 'World Clock',
      subtitle: 'View the local time for any location worldwide',
      bgColor: Color(0xFFFCE8E8),
      iconAsset: 'assets/clock 1.png',
    ),
    _ToolItem(
      title: 'Near by Places',
      subtitle: 'Shows nearby spots, shops, and attractions',
      bgColor: Color(0xFFEAF4EA),
      iconAsset: 'assets/loc.png',
      iconColor: Color(0xFFE53935), // Red pin to match location pins
    ),
    _ToolItem(
      title: 'Famous Places',
      subtitle: 'Discover landmarks around the globe',
      bgColor: Color(0xFFFFF8EC),
      iconAsset: 'assets/terrain.png',
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
                    'Calculation Tools',
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
class _ToolCard extends ConsumerWidget {
  const _ToolCard({required this.tool});

  final _ToolItem tool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (tool.title == 'Check Altitude') {
          Navigator.pushNamed(context, '/altitude_finder');
        } else if (tool.title == 'World Clock') {
          Navigator.pushNamed(context, '/world_clock');
        } else if (tool.title == 'Near by Places') {
          Navigator.pushNamed(context, '/nearby_places');
        } else if (tool.title == 'Famous Places') {
          Navigator.pushNamed(context, '/asia');
        } else if (tool.title == 'GPS Camera') {
          Navigator.pushNamed(context, '/gps_camera');
        } else if (tool.title == 'Find Distance') {
          Navigator.pushNamed(context, '/find_distance');
        } else if (tool.title == 'Find Traffic') {
          ref.read(activeTabProvider.notifier).state = 2; // Location tab
          ref.read(trafficLayerProvider.notifier).state = true; // Traffic layer active
          Navigator.pushNamed(context, '/asia');
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
            // Icon — top center
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