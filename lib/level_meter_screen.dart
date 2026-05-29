// lib/screens/level_meter_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

class LevelMeterScreen extends StatefulWidget {
  const LevelMeterScreen({super.key});

  @override
  State<LevelMeterScreen> createState() => _LevelMeterScreenState();
}

class _LevelMeterScreenState extends State<LevelMeterScreen> {
  // Coordinates of the floating bubble relative to center (0.0, 0.0)
  double _xOffset = 0.0;
  double _yOffset = 0.0;

  // Maximum drift radius inside the physical indicator
  static const double _maxRadius = 85.0;

  // Calibration offset variables
  double _xCalibration = 0.0;
  double _yCalibration = 0.0;

  bool _showCalibrateDialog = true; // Modal dialog visible by default

  // High accuracy condition: bubble is close to the center
  bool get _isHighAccuracy => math.sqrt(_xOffset * _xOffset + _yOffset * _yOffset) < 18.0;

  // Calculate degrees to display on axis cards
  double get _xAxisDegrees {
    double raw = (_xOffset / _maxRadius) * 45.0 - _xCalibration;
    return double.parse(raw.clamp(-45.0, 45.0).toStringAsFixed(1));
  }

  double get _yAxisDegrees {
    double raw = (-_yOffset / _maxRadius) * 45.0 - _yCalibration;
    return double.parse(raw.clamp(-45.0, 45.0).toStringAsFixed(1));
  }

  // Action to center bubble and calibrate
  void _performCalibration() {
    setState(() {
      _xCalibration = (_xOffset / _maxRadius) * 45.0;
      _yCalibration = (-_yOffset / _maxRadius) * 45.0;
      _xOffset = 0.0;
      _yOffset = 0.0;
      _showCalibrateDialog = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Device Calibrated Successfully!'),
          ],
        ),
        backgroundColor: const Color(0xFF1A7A68),
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
    final statusColor = _isHighAccuracy ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    final statusText = _isHighAccuracy ? 'High Accuracy' : 'Low Accuracy';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Level Meter',
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
            icon: Image.asset(
              'assets/Rotate.png',
              width: 24,
              height: 24,
              color: Colors.black,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.sync,
                color: Colors.black,
                size: 24,
              ),
            ),
            onPressed: () {
              setState(() {
                _showCalibrateDialog = true;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main Content Layout ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Spacer(),

                  // ── Interactive Bubble Level ──
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        // Drag to simulate tilt drift
                        double newX = _xOffset + details.delta.dx;
                        double newY = _yOffset + details.delta.dy;

                        // Constraint inside a circle of _maxRadius
                        double distance = math.sqrt(newX * newX + newY * newY);
                        if (distance <= _maxRadius) {
                          _xOffset = newX;
                          _yOffset = newY;
                        } else {
                          // Bind to maximum circle boundary edge
                          double angle = math.atan2(newY, newX);
                          _xOffset = _maxRadius * math.cos(angle);
                          _yOffset = _maxRadius * math.sin(angle);
                        }
                      });
                    },
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0ECE9), // Soft cyan/grey level background
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Custom Painter drawing the dynamic green/red arc boundary ring
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _LevelMeterPainter(isHighAccuracy: _isHighAccuracy),
                            ),
                          ),

                          // Target Center gridlines
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00796B).withOpacity(0.12),
                                width: 1.5,
                              ),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00796B).withOpacity(0.4),
                                width: 2.0,
                              ),
                            ),
                          ),

                          // Horizontal center pointer line
                          Container(
                            width: 1.5,
                            height: 60,
                            color: const Color(0xFF00796B).withOpacity(0.5),
                          ),
                          Container(
                            width: 60,
                            height: 1.5,
                            color: const Color(0xFF00796B).withOpacity(0.5),
                          ),

                          // Floating bubble (dynamically colored based on accuracy)
                          Transform.translate(
                            offset: Offset(_xOffset, _yOffset),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 15),
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: _isHighAccuracy
                                      ? [
                                          const Color(0xFF81C784),
                                          const Color(0xFF2E7D32),
                                        ]
                                      : [
                                          const Color(0xFFE57373),
                                          const Color(0xFFD32F2F),
                                        ],
                                  center: const Alignment(-0.3, -0.3),
                                  radius: 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Accuracy Indicator Text (Dynamically Colored)
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Place horizontally to adjust the level',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  // ── real-time Axis Cards (Row of 2) ──
                  Row(
                    children: [
                      // X Axis Card
                      Expanded(
                        child: _AxisCard(
                          label: 'X axis',
                          value: _xAxisDegrees,
                          iconPath: 'assets/x axis.png',
                          fallbackIcon: Icons.swap_horiz,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Y Axis Card
                      Expanded(
                        child: _AxisCard(
                          label: 'Y axis',
                          value: _yAxisDegrees,
                          iconPath: 'assets/y axis.png',
                          fallbackIcon: Icons.swap_vert,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── Premium Device Calibration Dialog Modal ──
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
                        // Title
                        const Text(
                          'Calibrate your device',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Instruction Subtext
                        const Text(
                          'Calibrate your device by moving it in these directions as shown below or by moving it in 8 pattern shape',
                          style: TextStyle(
                            fontSize: 14.5,
                            color: Color(0xFF6B7280),
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Calibration Visual Graphics (Row of 2)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Tilting phone icon
                            _CalibrationGraphic(
                              iconPath: 'assets/Rotate.png',
                              fallbackIcon: Icons.phonelink_setup,
                            ),
                            // Rotating phone icon
                            _CalibrationGraphic(
                              iconPath: 'assets/Rotate.png',
                              rotateAngle: math.pi / 2,
                              fallbackIcon: Icons.screen_rotation,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Actions Row (Cancel / Calibrate)
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
                                backgroundColor: const Color(0xFF1A7A68),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
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
}

// ── Custom Painter drawing the green top-arc or solid red boundary circle based on accuracy state ──
class _LevelMeterPainter extends CustomPainter {
  final bool isHighAccuracy;

  _LevelMeterPainter({required this.isHighAccuracy});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = isHighAccuracy ? const Color(0xFF0F5C12) : const Color(0xFFD32F2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    if (isHighAccuracy) {
      // High Accuracy Mode: Draw the dark green top arc (First Screenshot)
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 106),
        math.pi * 0.95,
        math.pi * 1.1,
        false,
        paint,
      );

      // Alignment central top notch
      final notchPaint = Paint()
        ..color = const Color(0xFF0F5C12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawLine(
        Offset(center.dx, center.dy - 106 + 6),
        Offset(center.dx, center.dy - 106 - 15),
        notchPaint,
      );
    } else {
      // Low Accuracy Mode: Draw the fully closed thick red boundary ring (Second Screenshot)
      canvas.drawCircle(center, 106, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LevelMeterPainter oldDelegate) {
    return oldDelegate.isHighAccuracy != isHighAccuracy;
  }
}

// ── Reusable Axis Degree Card ──
class _AxisCard extends StatelessWidget {
  final String label;
  final double value;
  final String iconPath;
  final IconData fallbackIcon;

  const _AxisCard({
    required this.label,
    required this.value,
    required this.iconPath,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 28,
            height: 28,
            errorBuilder: (_, __, ___) => Icon(
              fallbackIcon,
              color: const Color(0xFF1A7A68),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.abs().toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111111),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reusable Calibration Visual Graphic ──
class _CalibrationGraphic extends StatelessWidget {
  final String iconPath;
  final double rotateAngle;
  final IconData fallbackIcon;

  const _CalibrationGraphic({
    required this.iconPath,
    this.rotateAngle = 0.0,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotateAngle,
      child: Container(
        width: 85,
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: 44,
            height: 44,
            errorBuilder: (_, __, ___) => Icon(
              fallbackIcon,
              color: const Color(0xFF1A7A68),
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
