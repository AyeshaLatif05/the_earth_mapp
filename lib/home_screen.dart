// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/language_provider.dart';
import 'providers/travel_provider.dart';
import 'services/firebase_service.dart';
import 'services/location_service.dart';

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
    final tr = ref.read(translationProvider);
    final homeLoc = ref.read(homeLocationProvider);
    final TextEditingController controller = TextEditingController(
      text: homeLoc == 'Add Home Location'
          ? ''
          : homeLoc,
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
                    Text(
                      tr['update_place_name'] ?? 'Update Place Name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr['enter_location_suggestion'] ?? 'Enter location name or select a suggestion',
                      style: const TextStyle(
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
                    Text(
                      tr['suggestions'] ?? 'Suggestions',
                      style: const TextStyle(
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
                          child: Text(
                            tr['cancel'] ?? 'Cancel',
                            style: const TextStyle(
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
                          child: Text(
                            tr['save'] ?? 'Save',
                            style: const TextStyle(
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

  void _onMyLocationTapped(BuildContext context) async {
    final tr = ref.read(translationProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1A7A68),
        ),
      ),
    );

    try {
      final coords = await LocationService.getCurrentLocation();
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        Navigator.pushNamed(
          context,
          '/street_view',
          arguments: {
            'locationName': tr['my_location'] ?? 'My Location',
            'latitude': coords.latitude,
            'longitude': coords.longitude,
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr['could_not_get_location'] ?? 'Could not get current location: '}$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationProvider);

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
                _buildAppBar(context, tr),
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
                          child: _buildHomeLocationCard(tr),
                        ),
                        const SizedBox(height: 10),

                        // ── Live Earth Banner ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildLiveEarthBanner(context, tr),
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
                                tr['map_tools'] ?? 'Map Tools',
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
                                        title: tr['3d_earth_map'] ?? '3D Earth Map',
                                        subtitle: tr['explore_planet_satellite'] ??
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
                                        title: tr['my_location'] ?? 'My Location',
                                        subtitle: tr['find_current_position'] ??
                                            'Find your current position on the map',
                                        bgColor: const Color(0xFFFFF1F0),
                                        iconAsset: 'assets/image 3.png',
                                        onTap: () => _onMyLocationTapped(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Calculation Tools
                              _buildSectionHeader(
                                context,
                                tr['calculation_tools'] ?? 'Calculation Tools',
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
                                        title: tr['check_altitude'] ?? 'Check Altitude',
                                        subtitle: tr['explore_earth_3d'] ??
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
                                        title: tr['find_traffic'] ?? 'Find Traffic',
                                        subtitle: tr['see_traffic_updates'] ??
                                            'See real-time traffic updates on your route',
                                        bgColor: const Color(0xFFFEFBE8),
                                        iconAsset: 'assets/image 11.png',
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
                                tr['information_tools'] ?? 'Information Tools',
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
                                        title: tr['live_sensor'] ?? 'Live Sensor',
                                        subtitle: tr['real_time_sensor_data'] ??
                                            'Real-time data from your device sensors',
                                        bgColor: const Color(0xFFFFF0E6),
                                        iconAsset: 'assets/image 18.png',
                                        onTap: () => Navigator.pushNamed(
                                            context, '/live_sensor'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ToolCard(
                                        title: tr['oxygen_level'] ?? 'Oxygen Level',
                                        subtitle: tr['monitor_oxygen_quality'] ??
                                            'Monitor oxygen level and air quality',
                                        bgColor: const Color(0xFFF0F5FF),
                                        iconAsset: 'assets/image 14.png',
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
  Widget _buildAppBar(BuildContext context, Map<String, String> tr) {
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
          Text(
            tr['explore_earth'] ?? 'Explore Earth',
            style: const TextStyle(
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
  Widget _buildHomeLocationCard(Map<String, String> tr) {
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
                  Text(
                    tr['home'] ?? 'Home',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isEmpty ? (tr['add_home_location'] ?? 'Add Home Location') : homeLoc,
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
  Widget _buildLiveEarthBanner(BuildContext context, Map<String, String> tr) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/cameras'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A7A68),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr['live_earth_map'] ?? 'Live Earth Map',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr['explore_live_cameras'] ?? 'Explore Live Cameras and ...',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/image 1.png',
              width: 72,
              height: 72,
              fit: BoxFit.contain,
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
                width: 56,
                height: 56,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
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