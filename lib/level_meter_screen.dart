import 'dart:math' as math;
import 'package:flutter/material.dart';

class LevelMeterScreen extends StatefulWidget {
  const LevelMeterScreen({super.key});

  @override
  State<LevelMeterScreen> createState() => _LevelMeterScreenState();
}

class _LevelMeterScreenState extends State<LevelMeterScreen> {
  // Coordinates of the floating bubble relative to center (0.0, 0.0)
  // Positioned at custom starting tilt to match screenshot (-40, -40)
  double _xOffset = -38.0;
  double _yOffset = -36.0;

  // Maximum drift radius inside the physical indicator
  static const double _maxRadius = 90.0;

  // Calibration offset variables
  double _xCalibration = 0.0;
  double _yCalibration = 0.0;

  // Dialog hidden by default to match screenshot and prevent first-launch blocker
  bool _showCalibrateDialog = false; 

  // Primary green theme colors matching screenshot precisely
  final Color _greenRingColor = const Color(0xFF00C853); // Bright vibrant green border ring
  final Color _mintBgColor = const Color(0xFFDFF0EC);    // Light teal/mint inside circular background



  // Calculate degrees to display on axis cards
  double get _xAxisDegrees {
    double raw = (_xOffset / _maxRadius) * 45.0 - _xCalibration;
    return double.parse(raw.clamp(-45.0, 45.0).toStringAsFixed(1));
  }

  double get _yAxisDegrees {
    double raw = (-_yOffset / _maxRadius) * 45.0 - _yCalibration;
    return double.parse(raw.clamp(-45.0, 45.0).toStringAsFixed(1));
  }

  void _performCalibration() {
    setState(() {
      _xCalibration = (_xOffset / _maxRadius) * 45.0;
      _yCalibration = (-_yOffset / _maxRadius) * 45.0;
      _xOffset = 0.0;
      _yOffset = 0.0;
      _showCalibrateDialog = false;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Calibrated Successfully!'),
          ],
        ),
        backgroundColor: _greenRingColor,
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
    // Exact screenshot styling: vibrant bright green for "High Accuracy"
    final statusColor = _greenRingColor;
    const statusText = 'High Accuracy';

    return Scaffold(
      backgroundColor: Colors.white, // Pure white background from screenshot
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
          // Eye/Target Outline Icon from top-right of screenshot
          IconButton(
            icon: const Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.black,
              size: 26,
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

                  // ── Interactive Bubble Level Indicator ──
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        // Drag to simulate real-time phone tilting
                        double newX = _xOffset + details.delta.dx;
                        double newY = _yOffset + details.delta.dy;

                        double distance = math.sqrt(newX * newX + newY * newY);
                        if (distance <= _maxRadius) {
                          _xOffset = newX;
                          _yOffset = newY;
                        } else {
                          double angle = math.atan2(newY, newX);
                          _xOffset = _maxRadius * math.cos(angle);
                          _yOffset = _maxRadius * math.sin(angle);
                        }
                      });
                    },
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: _mintBgColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // ── Beautiful outer closed circular neon-green ring ──
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _LevelMeterPainter(
                                strokeColor: _greenRingColor,
                              ),
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
                          
                          // Inner target circle
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00796B),
                                width: 2.2,
                              ),
                            ),
                          ),

                          // Horizontal center pointer line
                          Container(
                            width: 2,
                            height: 60,
                            color: const Color(0xFF00796B),
                          ),
                          Container(
                            width: 60,
                            height: 2,
                            color: const Color(0xFF00796B),
                          ),

                          // Floating bubble (Solid vibrant green dot from screenshot)
                          Transform.translate(
                            offset: Offset(_xOffset, _yOffset),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 15),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _greenRingColor, // Solid bright green bubble
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 38),

                  // Accuracy Indicator Text matching screenshot colors
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Place horizontally to adjust the level',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  // ── Real-time Axis Cards (Matching screenshot gray style) ──
                  Row(
                    children: [
                      // X Axis Card
                      Expanded(
                        child: _AxisCard(
                          label: 'X axis',
                          value: _xAxisDegrees,
                          icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF1F1F1F), size: 26),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Y Axis Card
                      Expanded(
                        child: _AxisCard(
                          label: 'Y axis',
                          value: _yAxisDegrees,
                          icon: const Icon(Icons.swap_vert_rounded, color: Color(0xFF1F1F1F), size: 26),
                        ),
                      ),
                    ],
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
                          'Calibrate your device',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCalibrationGraphic(Icons.phonelink_setup, 0.0),
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
                                backgroundColor: _greenRingColor,
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
            color: _greenRingColor,
            size: 32,
          ),
        ),
      ),
    );
  }
}

// Custom Painter to draw the bright green closed circle ring precisely
class _LevelMeterPainter extends CustomPainter {
  final Color strokeColor;

  _LevelMeterPainter({required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    // Draw the full, thick closed vibrant green circular boundary ring matching screenshot
    canvas.drawCircle(center, 110, paint);
  }

  @override
  bool shouldRepaint(covariant _LevelMeterPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor;
  }
}

// Reusable Axis Card matching clean gray styling
class _AxisCard extends StatelessWidget {
  final String label;
  final double value;
  final Widget icon;

  const _AxisCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Gray card background from screenshot
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.abs().toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
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
