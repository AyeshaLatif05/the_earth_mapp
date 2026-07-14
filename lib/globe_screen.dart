import 'dart:math';
import 'package:flutter/material.dart';

class GlobeScreen extends StatefulWidget {
  const GlobeScreen({super.key});

  @override
  State<GlobeScreen> createState() => _GlobeScreenState();
}

class _GlobeScreenState extends State<GlobeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  final TransformationController _transformationController = TransformationController();
  final TextEditingController _searchController = TextEditingController();

  double _currentScale = 1.0;
  final List<Point<double>> _stars = [];

  @override
  void initState() {
    super.initState();
    // 50 seconds per rotation for a slow, premium movement
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    )..repeat();

    // Generate random stars for the background
    final random = Random();
    for (int i = 0; i < 120; i++) {
      _stars.add(Point(random.nextDouble(), random.nextDouble()));
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _transformationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _zoom(double factor) {
    setState(() {
      _currentScale = (_currentScale * factor).clamp(0.5, 3.0);
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _resetZoom() {
    setState(() {
      _currentScale = 1.0;
      _transformationController.value = Matrix4.identity();
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Position and zoom reset'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for "$query"... Centering globe.'),
        backgroundColor: const Color(0xFF1E7E6C),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // Simulate focusing/zooming on searched spot
    setState(() {
      _currentScale = 1.6;
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '3D Globe',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // ── 1. Starry Night Sky Background Painter ──
          Positioned.fill(
            child: CustomPaint(
              painter: StarrySkyPainter(stars: _stars),
            ),
          ),

          // ── 2. Rotating Glowing Earth Globe ──
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: 320,
                height: 320,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 3.0,
                  onInteractionUpdate: (details) {
                    // Update scale state tracking
                    _currentScale = _transformationController.value.getMaxScaleOnAxis();
                  },
                  child: Center(
                    child: RotationTransition(
                      turns: _rotationController,
                      child: Image.asset(
                        'assets/Globe Component.png',
                        width: 310,
                        height: 310,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.public, color: Colors.white, size: 64),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 3. Floating Top Search Location Bar ──
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _onSearch,
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Search your location',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 4. Zoom & Recenter Control Column ──
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCircleControl(
                  icon: Icons.add,
                  onTap: () => _zoom(1.2),
                ),
                const SizedBox(height: 10),
                _buildCircleControl(
                  icon: Icons.remove,
                  onTap: () => _zoom(0.8),
                ),
                const SizedBox(height: 10),
                _buildCircleControl(
                  icon: Icons.gps_fixed_rounded,
                  iconColor: const Color(0xFF1E7E6C),
                  onTap: _resetZoom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Floating Circle Control Helper Widget
  Widget _buildCircleControl({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF111111),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
    );
  }
}

// ── Custom Painter to render background stars ──
class StarrySkyPainter extends CustomPainter {
  final List<Point<double>> stars;

  StarrySkyPainter({required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    for (final star in stars) {
      final x = star.x * size.width;
      final y = star.y * size.height;
      // Draw standard stars of varying size/alpha based on coordinates
      final alpha = (star.x * 200 + 55).toInt().clamp(0, 255);
      paint.color = Colors.white.withAlpha(alpha);
      final radius = (star.y * 1.5 + 0.5);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
