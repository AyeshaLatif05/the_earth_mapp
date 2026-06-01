// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/travel_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['showUpdateDialog'] == true) {
        _showUpdatePlaceNameDialog();
      }
    });
  }

  void _showUpdatePlaceNameDialog() {
    final TextEditingController controller = TextEditingController(
      text: ref.read(homeLocationProvider) == 'Add Home Location'
          ? 'Location here, Rawalpindi, Pakistan'
          : ref.read(homeLocationProvider),
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Place Name',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter location name',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          ref.read(homeLocationProvider.notifier).state = controller.text.trim();
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A7A68),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E2A), // Deep dark indigo background
      body: Stack(
        children: [
          // ── Beautiful Globe Backdrop peeking from top ──
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            height: 320,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 0.85, 1.0],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/icon earth map.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.transparent,
                    child: const Icon(
                      Icons.public,
                      size: 180,
                      color: Color(0xFF1E88E5),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Scrollable content area ──
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Premium App Bar ──
                _buildAppBar(context),

                // ── Scrollable Body ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Space to showcase the beautiful earth globe graphic
                        const SizedBox(height: 70),

                        // ── Main Content Sheet (White Background) ──
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F6FA), // Sleek, light grey/white background
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              // ── Home Location Card ──
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: _buildHomeLocationCard(),
                              ),
                              const SizedBox(height: 12),

                              // ── Live Earth Map Promotional Card ──
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: _buildLiveEarthBanner(context),
                              ),
                              const SizedBox(height: 24),

                              // ── Map Tools Section ──
                              _buildSectionHeader(
                                context,
                                'Map Tools',
                                onTap: () {
                                  Navigator.pushNamed(context, '/map_tools');
                                },
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _ToolCard(
                                        title: '3D Earth Map',
                                        subtitle: 'Explore the planet using live satellite data',
                                        bgColor: const Color(0xFFE6F4FF), // Soft pastel blue
                                        iconAsset: 'assets/trav.png',
                                        onTap: () {
                                          Navigator.pushNamed(context, '/map_tools');
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ToolCard(
                                        title: 'My Location',
                                        subtitle: 'Find your current position on the map',
                                        bgColor: const Color(0xFFFFF1F0), // Soft pastel coral/red
                                        iconAsset: 'assets/loc.png',
                                        onTap: () {
                                          Navigator.pushNamed(context, '/map_tools');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── Calculation Tools Section ──
                              _buildSectionHeader(
                                context,
                                'Calculation Tools',
                                onTap: () {
                                  Navigator.pushNamed(context, '/calculation_tools');
                                },
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _ToolCard(
                                        title: 'Check Altitude',
                                        subtitle: 'Explore Earth in an interactive 3D view',
                                        bgColor: const Color(0xFFF9F0FF), // Soft pastel purple
                                        iconAsset: 'assets/level.png',
                                        onTap: () {
                                          Navigator.pushNamed(context, '/altitude_finder');
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ToolCard(
                                        title: 'Find Traffic',
                                        subtitle: 'See real-time traffic updates on your route',
                                        bgColor: const Color(0xFFFEFBE8), // Soft pastel yellow
                                        iconAsset: 'assets/dir.png',
                                        onTap: () {
                                          Navigator.pushNamed(context, '/map_tools');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── Information Tools Section ──
                              _buildSectionHeader(
                                context,
                                'Information Tools',
                                onTap: () {
                                  Navigator.pushNamed(context, '/information_tools');
                                },
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _ToolCard(
                                        title: 'Live Sensor',
                                        subtitle: 'Real-time data from your device sensors',
                                        bgColor: const Color(0xFFFFF0E6), // Soft pastel orange
                                        iconAsset: 'assets/speed.png',
                                        onTap: () {
                                          Navigator.pushNamed(context, '/information_tools');
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ToolCard(
                                        title: 'Oxygen Level',
                                        subtitle: 'Monitor oxygen level and air quality',
                                        bgColor: const Color(0xFFF0F5FF), // Soft pastel blue/grey
                                        iconAsset: 'assets/windy.png',
                                        onTap: () {
                                          Navigator.pushNamed(context, '/oxygen_level');
                                        },
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
        ],
      ),
    );
  }

  // ── Premium Top App Bar ──
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: Image.asset(
              'assets/menu.png',
              width: 24,
              height: 24,
              color: Colors.white,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.menu,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
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

  // ── Home Location Card ──────────────────────────────────────────────────────
  Widget _buildHomeLocationCard() {
    final homeLoc = ref.watch(homeLocationProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/loc.png',
            width: 28,
            height: 28,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.location_on,
              color: Color(0xFFE53935),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  homeLoc,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: homeLoc == 'Add Home Location' ? const Color(0xFF6B7280) : const Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showUpdatePlaceNameDialog,
            child: Image.asset(
              'assets/edit-2.png',
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.edit_outlined,
                color: Color(0xFF6B7280),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Live Earth Banner Card ──
  Widget _buildLiveEarthBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/cameras');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E7E6C),
              Color(0xFF136153),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E7E6C).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
              'assets/cam.png',
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
      ),
    );
  }

  // ── Section Header ──
  Widget _buildSectionHeader(BuildContext context, String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
              letterSpacing: -0.1,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/chevron-right.png',
                width: 20,
                height: 20,
                color: const Color(0xFF6B7280),
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6B7280),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Tool Card Widget ──
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
        height: 165,
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