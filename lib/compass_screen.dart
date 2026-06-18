import 'dart:math' as math;
import 'package:flutter/material.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  // Direct simulated rotation in radians
  double _headingRadians = 0.0;
  bool _showCalibrateDialog = false;

  int get _headingDegrees {
    int deg = (_headingRadians * 180 / math.pi).round() % 360;
    if (deg < 0) deg += 360;
    return deg;
  }

  String get _cardinalDirection {
    final int degrees = _headingDegrees;
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees >= 22.5 && degrees < 67.5) return 'NE';
    if (degrees >= 67.5 && degrees < 112.5) return 'E';
    if (degrees >= 112.5 && degrees < 157.5) return 'SE';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'SW';
    if (degrees >= 247.5 && degrees < 292.5) return 'W';
    return 'NW';
  }

  void _triggerCalibration() {
    setState(() {
      _showCalibrateDialog = true;
    });
  }

  void _performCalibration() {
    setState(() {
      _headingRadians = 0.0; // Reset heading to North
      _showCalibrateDialog = false;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Compass Calibrated Successfully!'),
          ],
        ),
        backgroundColor: const Color(0xFF1E7E6C),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Compass',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.explore_outlined, color: Colors.black, size: 26),
            onPressed: _triggerCalibration,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main Layout ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Spacer(),

                  // ── Title display (Degrees + Direction) ──
                  Column(
                    children: [
                      Text(
                        '$_headingDegrees°',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111111),
                          height: 1.0,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _cardinalDirection,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E7E6C),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── Rotatable Dial Container ──
                  GestureDetector(
                    onPanUpdate: (details) {
                      // Calculate the touch coordinate relative to widget center to rotate compass!
                      final RenderBox renderBox = context.findRenderObject() as RenderBox;
                      final Offset localPos = renderBox.globalToLocal(details.globalPosition);
                      
                      // Assuming center is roughly around half screen height
                      final Offset screenCenter = Offset(
                        renderBox.size.width / 2,
                        renderBox.size.height / 2 - 20, // offset slightly for appbar
                      );

                      final double dx = localPos.dx - screenCenter.dx;
                      final double dy = localPos.dy - screenCenter.dy;
                      
                      setState(() {
                        _headingRadians = math.atan2(dy, dx) + math.pi / 2;
                      });
                    },
                    child: Container(
                      width: 270,
                      height: 270,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF9FAFB),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Dial Outer Ring
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 2.0,
                              ),
                            ),
                          ),

                          // 2. Rotating compass plate
                          Transform.rotate(
                            angle: -_headingRadians,
                            child: CustomPaint(
                              size: const Size(240, 240),
                              painter: _CompassDialPainter(),
                            ),
                          ),

                          // 3. Static Center indicator Needle (Red pointer points UP always)
                          CustomPaint(
                            size: const Size(36, 120),
                            painter: _CompassNeedlePainter(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Telemetry Stats Card ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LATITUDE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '33.5973° N',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LONGITUDE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '73.0679° E',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACCURACY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '±3.2 meters',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E7E6C),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Rotate the dial or your device to orient',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── Calibration Dialog Modal ──
            if (_showCalibrateDialog)
              Container(
                color: Colors.black.withOpacity(0.4),
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Calibrate Compass',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Rotate your device in a figure-8 motion as shown below to recalibrate the magnetometer sensor.',
                          style: TextStyle(
                            fontSize: 14.5,
                            color: Color(0xFF6B7280),
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCalibrationGraphic(Icons.explore, 0.0),
                            _buildCalibrationGraphic(Icons.screen_rotation, math.pi / 2),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showCalibrateDialog = false;
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF6B7280),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _performCalibration,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E7E6C),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              ),
                              child: const Text(
                                'Calibrate',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationGraphic(IconData icon, double rotateAngle) {
    return Transform.rotate(
      angle: rotateAngle,
      child: Container(
        width: 85,
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            icon,
            color: const Color(0xFF1E7E6C),
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final textPaint = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Helper to draw direction letters
    void drawText(String text, double angle, Color color, double fontSize, bool isBold) {
      textPaint.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      );
      textPaint.layout();
      final double radAngle = angle * math.pi / 180 - math.pi / 2;
      final Offset textOffset = Offset(
        center.dx + (radius - 24) * math.cos(radAngle) - textPaint.width / 2,
        center.dy + (radius - 24) * math.sin(radAngle) - textPaint.height / 2,
      );
      canvas.save();
      canvas.translate(textOffset.dx + textPaint.width / 2, textOffset.dy + textPaint.height / 2);
      canvas.rotate(radAngle + math.pi / 2);
      canvas.translate(-textPaint.width / 2, -textPaint.height / 2);
      textPaint.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // Draw Cardinal points
    drawText('N', 0, const Color(0xFFD32F2F), 19, true);
    drawText('E', 90, const Color(0xFF111111), 16, false);
    drawText('S', 180, const Color(0xFF1E7E6C), 16, false);
    drawText('W', 270, const Color(0xFF111111), 16, false);

    // Draw Ordinals
    drawText('NE', 45, const Color(0xFF9CA3AF), 11, false);
    drawText('SE', 135, const Color(0xFF9CA3AF), 11, false);
    drawText('SW', 225, const Color(0xFF9CA3AF), 11, false);
    drawText('NW', 315, const Color(0xFF9CA3AF), 11, false);

    // Draw Dial ticks (Every 30 degrees)
    final tickPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 12; i++) {
      if (i % 3 == 0) continue; // skip N, E, S, W ticks
      final double angle = i * 30 * math.pi / 180;
      final Offset start = Offset(
        center.dx + (radius - 12) * math.cos(angle),
        center.dy + (radius - 12) * math.sin(angle),
      );
      final Offset end = Offset(
        center.dx + (radius - 4) * math.cos(angle),
        center.dy + (radius - 4) * math.sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final height = size.height;
    final width = size.width;

    final redPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.fill;

    final greyPaint = Paint()
      ..color = const Color(0xFFBDC3C7)
      ..style = PaintingStyle.fill;

    // Top half points UP (Red pointer)
    final redPath = Path()
      ..moveTo(center.dx, center.dy - height / 2)
      ..lineTo(center.dx - width / 2, center.dy)
      ..lineTo(center.dx, center.dy - 6)
      ..lineTo(center.dx + width / 2, center.dy)
      ..close();

    // Bottom half points DOWN (Grey pointer)
    final greyPath = Path()
      ..moveTo(center.dx, center.dy + height / 3)
      ..lineTo(center.dx - width / 3, center.dy)
      ..lineTo(center.dx, center.dy - 6)
      ..lineTo(center.dx + width / 3, center.dy)
      ..close();

    canvas.drawPath(redPath, redPaint);
    canvas.drawPath(greyPath, greyPaint);

    // Center rivet dot
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 4, centerPaint);
    canvas.drawCircle(center, 4, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
