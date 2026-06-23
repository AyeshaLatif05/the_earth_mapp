import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SpeedometerScreen extends StatefulWidget {
  const SpeedometerScreen({super.key});

  @override
  State<SpeedometerScreen> createState() => _SpeedometerScreenState();
}

class _SpeedometerScreenState extends State<SpeedometerScreen> with SingleTickerProviderStateMixin {
  double _currentSpeed = 0.0;
  double _maxSpeed = 0.0;
  double _totalSpeedAccumulated = 0.0;
  int _speedCount = 0;
  bool _isKmh = true;
  StreamSubscription<Position>? _positionStreamSubscription;

  void _startSpeedTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1,
    );
    try {
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        final speedInKmh = position.speed * 3.6;
        if (speedInKmh > 0) {
          _updateSpeed(speedInKmh);
        }
      }, onError: (err) {
        debugPrint('Speedometer Geolocator stream error: $err');
      });
    } catch (e) {
      debugPrint('Could not start Geolocator speed stream: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _startSpeedTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // Warning thresholds
  static const double _warningKmh = 110.0;
  static const double _warningMph = 70.0;

  void _resetMetrics() {
    setState(() {
      _maxSpeed = 0.0;
      _totalSpeedAccumulated = 0.0;
      _speedCount = 0;
      _currentSpeed = 0.0;
    });
  }

  double get _averageSpeed {
    if (_speedCount == 0) return 0.0;
    return double.parse((_totalSpeedAccumulated / _speedCount).toStringAsFixed(1));
  }

  void _updateSpeed(double newSpeed) {
    setState(() {
      _currentSpeed = newSpeed;
      if (newSpeed > _maxSpeed) {
        _maxSpeed = newSpeed;
      }
      if (newSpeed > 0) {
        _totalSpeedAccumulated += newSpeed;
        _speedCount++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double displaySpeed = _isKmh ? _currentSpeed : _currentSpeed * 0.621371;
    final double displayMax = _isKmh ? _maxSpeed : _maxSpeed * 0.621371;
    final double displayAvg = _isKmh ? _averageSpeed : _averageSpeed * 0.621371;
    final String unit = _isKmh ? 'km/h' : 'mph';
    final double limit = _isKmh ? _warningKmh : _warningMph;
    final bool isOverspeed = displaySpeed > limit;

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
          'Speedometer',
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
            icon: const Icon(Icons.refresh_rounded, color: Colors.black, size: 26),
            onPressed: _resetMetrics,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(),

              // ── Speed Warning Banner ──
              AnimatedOpacity(
                opacity: isOverspeed ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF9A9A), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Overspeed Warning! Exceeded $limit $unit',
                        style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Gauge Dial ──
              Center(
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: CustomPaint(
                    painter: _SpeedGaugePainter(
                      speed: displaySpeed,
                      maxSpeedLimit: _isKmh ? 180 : 110,
                      isOverspeed: isOverspeed,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            displaySpeed.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 68,
                              fontWeight: FontWeight.w900,
                              color: isOverspeed ? const Color(0xFFD32F2F) : const Color(0xFF111111),
                              height: 1.0,
                              letterSpacing: -1.0,
                            ),
                          ),
                          Text(
                            unit.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isOverspeed ? const Color(0xFFD32F2F) : const Color(0xFF9CA3AF),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ── Speed Statistics Cards ──
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'MAX SPEED',
                      value: '${displayMax.toStringAsFixed(0)} $unit',
                      icon: Icons.speed_rounded,
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _StatCard(
                      label: 'AVG SPEED',
                      value: '${displayAvg.toStringAsFixed(1)} $unit',
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFF1E7E6C),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Unit Switcher Choice Chips ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('KM/H', style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: _isKmh,
                    selectedColor: const Color(0xFF1E7E6C),
                    disabledColor: const Color(0xFFF3F4F6),
                    labelStyle: TextStyle(color: _isKmh ? Colors.white : const Color(0xFF4B5563)),
                    backgroundColor: const Color(0xFFF3F4F6),
                    onSelected: (val) {
                      if (val) setState(() => _isKmh = true);
                    },
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('MPH', style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: !_isKmh,
                    selectedColor: const Color(0xFF1E7E6C),
                    disabledColor: const Color(0xFFF3F4F6),
                    labelStyle: TextStyle(color: !_isKmh ? Colors.white : const Color(0xFF4B5563)),
                    backgroundColor: const Color(0xFFF3F4F6),
                    onSelected: (val) {
                      if (val) setState(() => _isKmh = false);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Speed Simulator Slider ──
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Speed Simulator',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              Slider(
                value: _currentSpeed,
                min: 0.0,
                max: 180.0,
                divisions: 180,
                activeColor: isOverspeed ? const Color(0xFFD32F2F) : const Color(0xFF1E7E6C),
                inactiveColor: const Color(0xFFE5E7EB),
                label: '${displaySpeed.toStringAsFixed(0)} $unit',
                onChanged: _updateSpeed,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
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

class _SpeedGaugePainter extends CustomPainter {
  final double speed;
  final double maxSpeedLimit;
  final bool isOverspeed;

  _SpeedGaugePainter({
    required this.speed,
    required this.maxSpeedLimit,
    required this.isOverspeed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final basePaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = isOverspeed ? const Color(0xFFD32F2F) : const Color(0xFF1E7E6C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    // Dial starts from 140 degrees to 400 degrees (260 degree sweep)
    const startAngle = 140.0 * math.pi / 180.0;
    const sweepAngle = 260.0 * math.pi / 180.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      startAngle,
      sweepAngle,
      false,
      basePaint,
    );

    final double speedRatio = (speed / maxSpeedLimit).clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      startAngle,
      sweepAngle * speedRatio,
      false,
      progressPaint,
    );

    // Draw gauge tick accents
    final tickPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 2.0;

    for (int i = 0; i <= 10; i++) {
      final double angle = startAngle + (sweepAngle * (i / 10));
      final Offset start = Offset(
        center.dx + (radius - 24) * math.cos(angle),
        center.dy + (radius - 24) * math.sin(angle),
      );
      final Offset end = Offset(
        center.dx + (radius - 18) * math.cos(angle),
        center.dy + (radius - 18) * math.sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedGaugePainter oldDelegate) {
    return oldDelegate.speed != speed ||
        oldDelegate.maxSpeedLimit != maxSpeedLimit ||
        oldDelegate.isOverspeed != isOverspeed;
  }
}
