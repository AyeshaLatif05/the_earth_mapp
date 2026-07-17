import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiveSensorScreen extends StatefulWidget {
  const LiveSensorScreen({super.key});

  @override
  State<LiveSensorScreen> createState() => _LiveSensorScreenState();
}

class _LiveSensorScreenState extends State<LiveSensorScreen> {
  Timer? _sensorTimer;
  final math.Random _random = math.Random();

  // Dynamic state values to simulate live ticking sensors
  double _accX = 0.05;
  double _accY = -0.12;
  double _accZ = 9.81;

  double _gravX = 0.00;
  double _gravY = 0.00;
  double _gravZ = 9.80;

  double _gyroX = 0.01;
  double _gyroY = -0.02;
  double _gyroZ = 0.00;

  double _lightX = 24.5;
  double _lightY = 0.0;
  double _lightZ = 0.0;

  double _linAccX = 0.02;
  double _linAccY = -0.04;
  double _linAccZ = 0.01;

  double _magX = 42.1;
  double _magY = -15.4;
  double _magZ = -28.9;

  double _orientX = 120.4;
  double _orientY = 1.2;
  double _orientZ = -2.5;

  @override
  void initState() {
    super.initState();
    // Simulate active sensor data streams changing in real time (250ms interval)
    _sensorTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!mounted) return;
      setState(() {
        _accX = 0.05 + (_random.nextDouble() * 0.1 - 0.05);
        _accY = -0.12 + (_random.nextDouble() * 0.1 - 0.05);
        _accZ = 9.81 + (_random.nextDouble() * 0.15 - 0.07);

        _gravX = 0.0 + (_random.nextDouble() * 0.02 - 0.01);
        _gravY = 0.0 + (_random.nextDouble() * 0.02 - 0.01);
        _gravZ = 9.8 + (_random.nextDouble() * 0.02 - 0.01);

        _gyroX = (_random.nextDouble() * 0.06 - 0.03);
        _gyroY = (_random.nextDouble() * 0.06 - 0.03);
        _gyroZ = (_random.nextDouble() * 0.04 - 0.02);

        _lightX = (20.0 + _random.nextDouble() * 15.0);

        _linAccX = (_random.nextDouble() * 0.08 - 0.04);
        _linAccY = (_random.nextDouble() * 0.08 - 0.04);
        _linAccZ = (_random.nextDouble() * 0.08 - 0.04);

        _magX = 42.1 + (_random.nextDouble() * 1.5 - 0.75);
        _magY = -15.4 + (_random.nextDouble() * 1.5 - 0.75);
        _magZ = -28.9 + (_random.nextDouble() * 1.5 - 0.75);

        _orientX = (120.4 + _random.nextDouble() * 2.0 - 1.0) % 360.0;
        _orientY = 1.2 + (_random.nextDouble() * 0.4 - 0.2);
        _orientZ = -2.5 + (_random.nextDouble() * 0.4 - 0.2);
      });
    });
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    super.dispose();
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Live Sensor',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: 0.82,
          children: [
            // 1. Accelerometer
            _buildSensorItem(
              title: 'Accelerometer',
              unit: '(m/s2)',
              lines: [
                'x = ${_accX.toStringAsFixed(2)}',
                'y = ${_accY.toStringAsFixed(2)}',
                'z = ${_accZ.toStringAsFixed(2)}',
              ],
            ),
            // 2. Gravity
            _buildSensorItem(
              title: 'Gravity',
              unit: '(m/s2)',
              lines: [
                'X = ${_gravX.toStringAsFixed(2)}',
                'Y = ${_gravY.toStringAsFixed(2)}',
                'Z = ${_gravZ.toStringAsFixed(2)}',
              ],
            ),
            // 3. Gyroscope
            _buildSensorItem(
              title: 'Gyroscope',
              unit: '(rad/s)',
              lines: [
                'X = ${_gyroX.toStringAsFixed(3)}',
                'Y = ${_gyroY.toStringAsFixed(3)}',
                'Z = ${_gyroZ.toStringAsFixed(3)}',
              ],
            ),
            // 4. Light
            _buildSensorItem(
              title: 'Light',
              unit: '(lx)',
              lines: [
                'x = ${_lightX.toStringAsFixed(1)}',
                'y = ${_lightY.toStringAsFixed(1)}',
                'z = ${_lightZ.toStringAsFixed(1)}',
              ],
            ),
            // 5. Linear Accelerometer
            _buildSensorItem(
              title: 'Linear\nAccelerometer',
              unit: '(m/s2)',
              lines: [
                'X = ${_linAccX.toStringAsFixed(2)}',
                'Y = ${_linAccY.toStringAsFixed(2)}',
                'Z = ${_linAccZ.toStringAsFixed(2)}',
              ],
            ),
            // 6. Magnetic Field
            _buildSensorItem(
              title: 'Magnetic Field',
              unit: '(lx)',
              lines: [
                'X = ${_magX.toStringAsFixed(1)}',
                'Y = ${_magY.toStringAsFixed(1)}',
                'Z = ${_magZ.toStringAsFixed(1)}',
              ],
            ),
            // 7. Orientation
            _buildSensorItem(
              title: 'Orientation',
              unit: '(degree)',
              lines: [
                'X = ${_orientX.toStringAsFixed(1)}',
                'Y = ${_orientY.toStringAsFixed(1)}',
                'Z = ${_orientZ.toStringAsFixed(1)}',
              ],
            ),
            // 8. Pressure
            _buildUnsupportedSensorItem(
              title: 'Pressure',
              unit: '(hPa)',
              message: 'Sensor not supported',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorItem({
    required String title,
    required String unit,
    required List<String> lines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F766E), // Teal
            height: 1.15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6), // Light Grey Card
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: lines
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        line,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnsupportedSensorItem({
    required String title,
    required String unit,
    required String message,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F766E),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
