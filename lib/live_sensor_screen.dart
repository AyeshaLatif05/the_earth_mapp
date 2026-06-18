import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiveSensorScreen extends StatefulWidget {
  const LiveSensorScreen({super.key});

  @override
  State<LiveSensorScreen> createState() => _LiveSensorScreenState();
}

class _LiveSensorScreenState extends State<LiveSensorScreen> {
  // Timer to animate telemetry values slightly to simulate live tracking
  Timer? _simulationTimer;
  final math.Random _random = math.Random();

  // Simulated live metrics
  double _heading = 120.0;
  double _tiltX = 1.2;
  double _tiltY = -2.4;
  double _altitude = 542.0;
  double _oxygen = 98.0;

  @override
  void initState() {
    super.initState();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!mounted) return;
      setState(() {
        // Jitter the sensors slightly
        _heading = (_heading + _random.nextDouble() * 4 - 2) % 360;
        _tiltX = double.parse((_tiltX + _random.nextDouble() * 0.4 - 0.2).toStringAsFixed(1));
        _tiltY = double.parse((_tiltY + _random.nextDouble() * 0.4 - 0.2).toStringAsFixed(1));
        _altitude = double.parse((_altitude + _random.nextDouble() * 2 - 1).toStringAsFixed(1));
        _oxygen = (96.0 + _random.nextDouble() * 3.5).clamp(95.0, 100.0);
      });
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  String _headingDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees >= 22.5 && degrees < 67.5) return 'NE';
    if (degrees >= 67.5 && degrees < 112.5) return 'E';
    if (degrees >= 112.5 && degrees < 157.5) return 'SE';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'SW';
    if (degrees >= 247.5 && degrees < 292.5) return 'W';
    return 'NW';
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
          'Live Sensor Cockpit',
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Live Telemetry Dashboard',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 16),

              // ── Grid of Sensor Cards ──
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.88,
                children: [
                  // 1. Compass Sensor Card
                  _SensorCard(
                    title: 'Compass Heading',
                    value: '${_heading.toStringAsFixed(0)}° ${_headingDirection(_heading)}',
                    subtitle: 'Direction Tracking',
                    icon: Icons.explore_rounded,
                    bgColor: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF1976D2),
                    onTap: () => Navigator.pushNamed(context, '/compass'),
                  ),

                  // 2. Level Meter Card
                  _SensorCard(
                    title: 'Level & Tilt',
                    value: 'X: $_tiltX°  Y: $_tiltY°',
                    subtitle: 'Surface Incline',
                    icon: Icons.crop_free_rounded,
                    bgColor: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF388E3C),
                    onTap: () => Navigator.pushNamed(context, '/level_meter'),
                  ),

                  // 3. Altitude Card
                  _SensorCard(
                    title: 'Altimeter',
                    value: '${_altitude.toStringAsFixed(0)} m',
                    subtitle: 'Height Above Sea Level',
                    icon: Icons.landscape_rounded,
                    bgColor: const Color(0xFFF3E5F5),
                    iconColor: const Color(0xFF7B1FA2),
                    onTap: () => Navigator.pushNamed(context, '/altitude_finder'),
                  ),

                  // 4. Oxygen Level Card
                  _SensorCard(
                    title: 'Oxygen Air',
                    value: '${_oxygen.toStringAsFixed(1)} %',
                    subtitle: 'Air Quality (Good)',
                    icon: Icons.bubble_chart_rounded,
                    bgColor: const Color(0xFFE0F7FA),
                    iconColor: const Color(0xFF0097A7),
                    onTap: () => Navigator.pushNamed(context, '/oxygen_level'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Device Health Diagnostics Panel ──
              const Text(
                'Sensor Diagnostics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  children: [
                    _DiagnosticRow(
                      label: 'Magnetometer Status',
                      status: 'CALIBRATED',
                      color: const Color(0xFF1E7E6C),
                    ),
                    const Divider(height: 20, color: Color(0xFFE5E7EB)),
                    _DiagnosticRow(
                      label: 'Accelerometer Status',
                      status: 'STABLE',
                      color: const Color(0xFF1E7E6C),
                    ),
                    const Divider(height: 20, color: Color(0xFFE5E7EB)),
                    _DiagnosticRow(
                      label: 'Barometer Calibration',
                      status: 'AUTO-SYNCED',
                      color: const Color(0xFF1976D2),
                    ),
                    const Divider(height: 20, color: Color(0xFFE5E7EB)),
                    _DiagnosticRow(
                      label: 'Air Quality Index',
                      status: 'AQI: 35 (Good)',
                      color: const Color(0xFF388E3C),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _SensorCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: bgColor.withOpacity(0.8), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  final String label;
  final String status;
  final Color color;

  const _DiagnosticRow({
    required this.label,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
