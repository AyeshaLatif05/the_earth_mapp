// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/travel_provider.dart';
import 'services/firebase_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 45),
      vsync: this,
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final savedLoc = await FirebaseService.instance.getHomeLocation();
        if (savedLoc != null && mounted) {
          ref.read(homeLocationProvider.notifier).state = savedLoc;
        }
      } catch (e) {
        debugPrint("Failed to load home location: $e");
      }

      if (!mounted) return;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['showUpdateDialog'] == true) {
        _showUpdatePlaceNameDialog();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _showUpdatePlaceNameDialog() {
    final TextEditingController controller = TextEditingController(
      text: ref.read(homeLocationProvider) == 'Add Home Location'
          ? ''
          : ref.read(homeLocationProvider),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                      'Enter location name or select a suggestion',
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
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Suggestions',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'New York',
                        'London',
                        'Paris',
                        'Tokyo',
                        'Istanbul',
                      ].map((city) {
                        final bool isSelectedCity = controller.text.trim().toLowerCase() == city.toLowerCase();
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              controller.text = city;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelectedCity
                                    ? const Color(0xFF1A7A68)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              city,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelectedCity
                                    ? const Color(0xFF1A7A68)
                                    : const Color(0xFF374151),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
                          onPressed: () async {
                            final text = controller.text.trim();
                            if (text.isNotEmpty) {
                              ref.read(homeLocationProvider.notifier).state = text;
                              try {
                                await FirebaseService.instance.saveHomeLocation(text);
                              } catch (e) {
                                debugPrint("Failed to save home location: $e");
                              }
                            }
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A7A68),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E2A),
      body: Stack(
        children: [
          // ── Globe backdrop — centered, large, top-anchored ──
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            height: 320,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black,
                    Color(0xCC000000),
                    Color(0x44000000),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.35, 0.6, 0.82, 1.0],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: RotationTransition(
                turns: _rotationController,
                child: Image.asset(
                  'assets/Globe Component.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // ── Dark-to-transparent overlay so globe blends into bg ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF01001F), // solid dark at very top
                      Color(0x8821203B), // semi-dark mid
                      Color(0x33414057), // lighter
                      Color(0x00FFFFFF), // transparent
                    ],
                    stops: [0.0, 0.40, 0.70, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Main content ──
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // App bar
                _buildAppBar(context),
                const SizedBox(height: 8),

                // Scrollable body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Globe spacer — matches globe visual height
                        const SizedBox(height: 130),

                        // ── Home Location Card ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildHomeLocationCard(),
                        ),
                        const SizedBox(height: 10),

                        // ── Live Earth Banner ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildLiveEarthBanner(context),
                        ),
                        const SizedBox(height: 16),

                        // ── White content sheet ──
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 22),

                              // Map Tools
                              _buildSectionHeader(
                                context,
                                'Map Tools',
                                onTap: () => Navigator.pushNamed(
                                    context, '/map_tools'),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _ToolCard(
                                        title: '3D Earth Map',
                                        subtitle:
                                            'Explore the planet using live satellite data',
                                        bgColor: const Color(0xFFE6F4FF),
                                        iconAsset: 'assets/image 21.png',
                                        onTap: () => Navigator.pushNamed(
                                            context, '/street_view'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ToolCard(
                                        title: 'My Location',
                                        subtitle:
                                            'Find your current position on the map',
                                        bgColor: const Color(0xFFFFF1F0),
                                        iconAsset: 'assets/loc.png',
                                        iconColor: const Color(0xFFE53935),
                                        onTap: () => Navigator.pushNamed(
                                            context, '/street_view',
                                            arguments: {'locationName': 'My Location'}),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Calculation Tools
                              _buildSectionHeader(
                                context,
                                'Calculation Tools',
                                onTap: () => Navigator.pushNamed(
                                    context, '/calculation_tools'),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _ToolCard(
                                        title: 'Check Altitude',
                                        subtitle:
                                            'Explore Earth in an interactive 3D view',
                                        bgColor: const Color(0xFFF3EEFF),
                                        iconAsset: 'assets/image 10.png',
                                        onTap: () => Navigator.pushNamed(
                                            context, '/altitude_finder'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ToolCard(
                                        title: 'Find Traffic',
                                        subtitle:
                                            'See real-time traffic updates on your route',
                                        bgColor: const Color(0xFFFEFBE8),
                                        iconAsset: 'assets/dir.png',
                                        onTap: () {
                                          ref.read(activeTabProvider.notifier).state = 2; // Location tab
                                          ref.read(trafficLayerProvider.notifier).state = true; // Traffic layer active
                                          Navigator.pushNamed(context, '/asia');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Information Tools
                              _buildSectionHeader(
                                context,
                                'Information Tools',
                                onTap: () => Navigator.pushNamed(
                                    context, '/information_tools'),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _ToolCard(
                                        title: 'Live Sensor',
                                        subtitle:
                                            'Real-time data from your device sensors',
                                        bgColor: const Color(0xFFFFF0E6),
                                        iconAsset: 'assets/speed.png',
                                        iconColor: const Color(0xFFE65100),
                                        onTap: () => Navigator.pushNamed(
                                            context, '/live_sensor'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ToolCard(
                                        title: 'Oxygen Level',
                                        subtitle:
                                            'Monitor oxygen level and air quality',
                                        bgColor: const Color(0xFFF0F5FF),
                                        iconAsset: 'assets/image 14.png',
                                        iconColor: const Color(0xFF1E88E5),
                                        onTap: () => Navigator.pushNamed(
                                            context, '/oxygen_level'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Bottom padding for safe area / nav bar
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

  // ── App Bar ──
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Home Location Card ──
  Widget _buildHomeLocationCard() {
    final homeLoc = ref.watch(homeLocationProvider);
    final bool isEmpty = homeLoc == 'Add Home Location';
    return GestureDetector(
      onTap: () {
        if (isEmpty) {
          _showUpdatePlaceNameDialog();
        } else {
          Navigator.pushNamed(
            context,
            '/street_view',
            arguments: {'locationName': homeLoc},
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Red location pin
            Image.asset(
              'assets/loc.png',
              width: 28,
              height: 28,
              color: const Color(0xFFE53935),
              errorBuilder: (_, __, ___) => const Icon(
                Icons.location_on,
                color: Color(0xFFE53935),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    homeLoc,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isEmpty
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF111111),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // Open dialog explicitly when tapping the edit icon
                _showUpdatePlaceNameDialog();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Image.asset(
                  'assets/edit-2.png',
                  width: 20,
                  height: 20,
                  color: const Color(0xFF6B7280),
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Live Earth Banner ──
  Widget _buildLiveEarthBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/cameras'),
      child: Container(
        width: double.infinity,
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
              color: const Color(0xFF1A7A68).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Live Earth Map',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Explore Live Cameras and ...',
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/image 1.png',
              scale:4,
              
              errorBuilder: (_, __, ___) => const Icon(
                Icons.videocam_outlined,
                color: Colors.white70,
                size: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ──
  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    required VoidCallback onTap,
  }) {
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
        ],
      ),
    );
  }
}

// ── Tool Card ──
class _ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color bgColor;
  final String iconAsset;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ToolCard({
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
        height: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Icon — top right
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                iconAsset,
                width: 48,
                height: 48,
                color: iconColor,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Title + subtitle — bottom left
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF6B7280),
                      height: 1.35,
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