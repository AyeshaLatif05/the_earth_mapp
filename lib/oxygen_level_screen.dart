// lib/screens/oxygen_level_screen.dart

import 'package:flutter/material.dart';

class OxygenLevelScreen extends StatefulWidget {
  const OxygenLevelScreen({super.key});

  @override
  State<OxygenLevelScreen> createState() => _OxygenLevelScreenState();
}

class _OxygenLevelScreenState extends State<OxygenLevelScreen> {
  // Oxygen percentage level (0 to 100)
  double _oxygenLevel = 20.0;

  // Height of the vertical slider bar
  static const double _sliderHeight = 280.0;

  // Drag updates for vertical level selection
  void _updateSliderValue(double localY) {
    // Invert because Y is 0 at top and increases downwards
    double percentage = ((_sliderHeight - localY) / _sliderHeight) * 100.0;
    setState(() {
      _oxygenLevel = percentage.clamp(0.0, 100.0);
    });
  }

  // Handle Share functionality
  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.share, color: Colors.white),
            SizedBox(width: 10),
            Text('Location Shared successfully!'),
          ],
        ),
        backgroundColor: const Color(0xFF1E7E6C),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Normalizing the slider height fill
    double fillHeight = (_oxygenLevel / 100.0) * _sliderHeight;
    double arrowYOffset = _sliderHeight - fillHeight - 8.0; // center arrow slightly

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
          'Oxygen Level',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(),

              // ── Interactive Vertical Slider & Scale Ruler ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Ticks Scale Ruler on Left
                  SizedBox(
                    height: _sliderHeight + 10,
                    width: 75,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildRulerLabel('Max'),
                        _buildRulerLabel('70'),
                        _buildRulerLabel('60'),
                        _buildRulerLabel('50'),
                        _buildRulerLabel('40'),
                        _buildRulerLabel('30'),
                        _buildRulerLabel('20'),
                        _buildRulerLabel('10'),
                        _buildRulerLabel('0'),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 2. Custom ticks lines
                  SizedBox(
                    height: _sliderHeight + 10,
                    width: 20,
                    child: CustomPaint(
                      painter: _RulerTicksPainter(),
                    ),
                  ),

                  // 3. Interactive Vertical Slider Bar
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      _updateSliderValue(details.localPosition.dy);
                    },
                    onTapDown: (details) {
                      _updateSliderValue(details.localPosition.dy);
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Slider grey hollow container
                        Container(
                          width: 26,
                          height: _sliderHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                        ),

                        // Slider filled teal liquid level indicator
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: fillHeight,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E7E6C),
                              borderRadius: BorderRadius.only(
                                bottomLeft: const Radius.circular(13),
                                bottomRight: const Radius.circular(13),
                                topLeft: Radius.circular(fillHeight >= _sliderHeight ? 13 : 0),
                                topRight: Radius.circular(fillHeight >= _sliderHeight ? 13 : 0),
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF2EA690),
                                  Color(0xFF1E7E6C),
                                  Color(0xFF126153),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Sliding Yellow Arrow Pointer
                        Positioned(
                          left: 36,
                          top: arrowYOffset.clamp(0.0, _sliderHeight - 16.0),
                          child: CustomPaint(
                            size: const Size(12, 16),
                            painter: _YellowArrowPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // balance visual alignment
                ],
              ),

              const SizedBox(height: 38),

              // "Based on your GPS" subtitle
              const Text(
                'Based on your GPS',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),

              const SizedBox(height: 14),

              // Large Prominent Percentage Teal Card
              Container(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E7E6C),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E7E6C).withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${_oxygenLevel.round()}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ── GPS Bottom Location Card ──
              _buildGPSLocationCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Ruler labels widget helper
  Widget _buildRulerLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  // GPS Location card helper
  Widget _buildGPSLocationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.08),
          width: 1,
        ),
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
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Location here, Rawalpindi, Pakistan',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Image.asset(
              'assets/share-2.png',
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.share_outlined,
                color: Color(0xFF111111),
                size: 22,
              ),
            ),
            onPressed: _shareLocation,
          ),
        ],
      ),
    );
  }
}

// ── Custom Painter drawing Ruler Scale Tick Lines ──
class _RulerTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double spacing = size.height / 8.0;

    // Draw main scale line
    canvas.drawLine(
      Offset(size.width - 2, 5),
      Offset(size.width - 2, size.height - 5),
      paint,
    );

    // Draw 9 main tick marks
    for (int i = 0; i <= 8; i++) {
      double y = 5 + (i * spacing);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );

      // Draw 4 subdivisions between each major tick
      if (i < 8) {
        double subSpacing = spacing / 5.0;
        for (int j = 1; j <= 4; j++) {
          double subY = y + (j * subSpacing);
          canvas.drawLine(
            Offset(size.width / 2, subY),
            Offset(size.width, subY),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Custom Painter drawing sliding Yellow Pointer Triangle ──
class _YellowArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFBC02D) // Yellow arrow color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height / 2); // left tip
    path.lineTo(size.width, 0); // top right
    path.lineTo(size.width, size.height); // bottom right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
