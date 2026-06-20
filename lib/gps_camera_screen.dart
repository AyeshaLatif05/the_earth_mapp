// lib/gps_camera_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';

class GPSCameraScreen extends StatefulWidget {
  const GPSCameraScreen({super.key});

  @override
  State<GPSCameraScreen> createState() => _GPSCameraScreenState();
}

class _GPSCameraScreenState extends State<GPSCameraScreen> with SingleTickerProviderStateMixin {
  final Color _primaryColor = const Color(0xFF1E7E6C);

  // Time tracker for watermark
  late Timer _timeTimer;
  String _currentTime = '';
  String _currentDate = '';

  // Camera flash animation trigger
  double _flashOpacity = 0.0;

  // Selected mock location preset
  String _selectedCity = 'Rawalpindi';
  double _latitude = 33.5973;
  double _longitude = 73.0679;
  double _altitude = 512.0;
  String _address = 'Rawalpindi, Punjab, Pakistan';
  
  // Unsplash image preset representing the camera viewfinder backdrop
  final Map<String, String> _cityImages = {
    'Rawalpindi': 'https://images.unsplash.com/photo-1627626775846-122b778965ae?w=800&auto=format&fit=crop&q=80',
    'Tokyo': 'https://images.unsplash.com/photo-1540959733332-eab4deceeaf7?w=800&auto=format&fit=crop&q=80',
    'New York': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800&auto=format&fit=crop&q=80',
    'London': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800&auto=format&fit=crop&q=80',
    'Paris': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800&auto=format&fit=crop&q=80',
    'Istanbul': 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=800&auto=format&fit=crop&q=80',
  };

  final List<Map<String, dynamic>> _locationPresets = [
    {
      'city': 'Rawalpindi',
      'lat': 33.5973,
      'lng': 73.0679,
      'alt': 512.0,
      'address': 'Rawalpindi, Punjab, Pakistan',
    },
    {
      'city': 'Tokyo',
      'lat': 35.6762,
      'lng': 139.6503,
      'alt': 40.0,
      'address': 'Shibuya, Tokyo, Japan',
    },
    {
      'city': 'New York',
      'lat': 40.7128,
      'lng': -74.0060,
      'alt': 10.0,
      'address': 'Times Square, New York, NY, USA',
    },
    {
      'city': 'London',
      'lat': 51.5074,
      'lng': -0.1278,
      'alt': 35.0,
      'address': 'Westminster, London, UK',
    },
    {
      'city': 'Paris',
      'lat': 48.8566,
      'lng': 2.3522,
      'alt': 76.0,
      'address': 'Eiffel Tower, Paris, France',
    },
    {
      'city': 'Istanbul',
      'lat': 41.0082,
      'lng': 28.9784,
      'alt': 120.0,
      'address': 'Fatih, Istanbul, Turkey',
    },
  ];

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTime();
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
      final minute = now.minute.toString().padLeft(2, '0');
      final second = now.second.toString().padLeft(2, '0');
      final period = now.hour >= 12 ? 'PM' : 'AM';
      _currentTime = '$hour:$minute:$second $period';

      final year = now.year;
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');
      _currentDate = '$year-$month-$day';
    });
  }

  @override
  void dispose() {
    _timeTimer.cancel();
    super.dispose();
  }

  // Trigger flash and photo save simulation
  void _takePhoto() {
    setState(() {
      _flashOpacity = 1.0;
    });

    // Animate flash fading out quickly
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _flashOpacity = 0.0;
        });
      }
    });

    // Show captured overlay dialogue
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _showCapturedDialog();
      }
    });
  }

  void _showCapturedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Success Indicator
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F4F1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: _primaryColor,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Photo Saved!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Saved with location watermark successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Preview Thumbnail with simulated stamped metadata
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            _cityImages[_selectedCity]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Watermark Stamp overlay
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, color: Color(0xFFE53935), size: 10),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        _address,
                                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Lat: ${_latitude.toStringAsFixed(4)}  Lng: ${_longitude.toStringAsFixed(4)}  Alt: ${_altitude.toStringAsFixed(0)} m',
                                  style: const TextStyle(color: Colors.white70, fontSize: 7, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Date: $_currentDate  Time: $_currentTime',
                                  style: const TextStyle(color: Colors.white70, fontSize: 7, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Location selector bottom sheet
  void _showLocationPresetSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Simulate Camera Location',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _locationPresets.length,
                    itemBuilder: (context, idx) {
                      final preset = _locationPresets[idx];
                      final bool isSel = preset['city'] == _selectedCity;

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFE6F4F1) : const Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: isSel ? _primaryColor : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        title: Text(
                          preset['city'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                            color: isSel ? _primaryColor : const Color(0xFF1F1F1F),
                          ),
                        ),
                        subtitle: Text(
                          preset['address'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        trailing: isSel
                            ? Icon(Icons.check_circle_rounded, color: _primaryColor)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCity = preset['city'];
                            _latitude = preset['lat'];
                            _longitude = preset['lng'];
                            _altitude = preset['alt'];
                            _address = preset['address'];
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark camera UI
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'GPS Camera',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
        actions: [
          // Simulated location configuration button
          TextButton.icon(
            onPressed: _showLocationPresetSelector,
            icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
            label: Text(
              _selectedCity,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Main Viewfinder Frame ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        // Viewfinder background image
                        Positioned.fill(
                          child: Image.network(
                            _cityImages[_selectedCity]!,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Viewfinder focal gridlines
                        const Positioned.fill(
                          child: _ViewfinderGridlines(),
                        ),

                        // GPS Location Telemetry Overlay Watermark (bottom-left)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12, width: 1.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xFFE53935),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _address,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Latitude: ${_latitude.toStringAsFixed(4)}° N',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      'Longitude: ${_longitude.toStringAsFixed(4)}° E',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Altitude: ${_altitude.toStringAsFixed(1)} m',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      'Time: $_currentTime',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Date: $_currentDate',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Flash Overlay Indicator
                        Positioned.fill(
                          child: IgnorePointer(
                            child: AnimatedOpacity(
                              opacity: _flashOpacity,
                              duration: const Duration(milliseconds: 50),
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Camera Control Bar (Shutter button) ──
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Presets button
                  IconButton(
                    onPressed: _showLocationPresetSelector,
                    icon: const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 28),
                  ),

                  // Circular shutter trigger button
                  GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 3),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/Shutter.png',
                            width: 32,
                            height: 32,
                            color: Colors.black,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Info button
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Watermark camera embeds live coordinate stamps on your snaps.'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
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

// Custom Viewfinder Gridlines Painter
class _ViewfinderGridlines extends StatelessWidget {
  const _ViewfinderGridlines();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridlinesPainter(),
    );
  }
}

class _GridlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw horizontal lines at 1/3 and 2/3 height
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, 2 * size.height / 3), Offset(size.width, 2 * size.height / 3), paint);

    // Draw vertical lines at 1/3 and 2/3 width
    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(2 * size.width / 3, 0), Offset(2 * size.width / 3, size.height), paint);

    // Draw focal corners
    final cornerPaint = Paint()
      ..color = const Color(0xFF1E7E6C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    const double len = 16.0;
    const double pad = 40.0;

    // Top-Left corner
    canvas.drawPath(Path()..moveTo(pad, pad + len)..lineTo(pad, pad)..lineTo(pad + len, pad), cornerPaint);
    // Top-Right corner
    canvas.drawPath(Path()..moveTo(size.width - pad, pad + len)..lineTo(size.width - pad, pad)..lineTo(size.width - pad - len, pad), cornerPaint);
    // Bottom-Left corner
    canvas.drawPath(Path()..moveTo(pad, size.height - pad - len)..lineTo(pad, size.height - pad)..lineTo(pad + len, size.height - pad), cornerPaint);
    // Bottom-Right corner
    canvas.drawPath(Path()..moveTo(size.width - pad, size.height - pad - len)..lineTo(size.width - pad, size.height - pad)..lineTo(size.width - pad - len, size.height - pad), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
