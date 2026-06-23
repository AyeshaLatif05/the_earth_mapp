// lib/screens/voice_navigation_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'services/location_service.dart';

class VoiceNavigationScreen extends StatefulWidget {
  const VoiceNavigationScreen({super.key});

  @override
  State<VoiceNavigationScreen> createState() => _VoiceNavigationScreenState();
}

class _VoiceNavigationScreenState extends State<VoiceNavigationScreen> {
  GoogleMapController? _mapController;

  // Beşiktaş coordinates matching the screenshot
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.0438, 29.0067),
    zoom: 14.2,
  );

  bool _is3DView = false;
  MapType _mapType = MapType.normal;
  bool _trafficEnabled = false;

  bool _voiceGuidanceActive = false;
  String _currentAddress = 'Loading location...';
  LatLng _currentLatLng = const LatLng(41.0438, 29.0067);
  bool _isLoading = false;

  Future<String?> _fetchAddress(LatLng position) async {
    final lat = position.latitude;
    final lng = position.longitude;
    try {
      final reverseGeocodeUri = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json');
      final headers = {'User-Agent': 'LiveEarthMap/1.0 (contact@example.com)'};
      final response = await http.get(reverseGeocodeUri, headers: headers).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] as String?;
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    }
    return null;
  }

  void _loadInitialLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final coords = await LocationService.getCurrentLocation();
      final address = await _fetchAddress(coords);
      if (mounted) {
        setState(() {
          _currentLatLng = coords;
          if (address != null) {
            _currentAddress = address;
          } else {
            _currentAddress = 'Lat: ${coords.latitude.toStringAsFixed(4)}, Lng: ${coords.longitude.toStringAsFixed(4)}';
          }
          _isLoading = false;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(coords),
        );
      }
    } catch (e) {
      debugPrint('Error loading initial location: $e');
      if (mounted) {
        setState(() {
          _currentAddress = 'Location: Lat 41.0438, Lng 29.0067';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialLocation();
    });
  }

  // Location share trigger
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

  // Voice navigation started speech simulation trigger
  void _toggleVoiceNavigation() {
    setState(() {
      _voiceGuidanceActive = !_voiceGuidanceActive;
    });

    if (_voiceGuidanceActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.record_voice_over, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Voice guidance started! "Head northeast towards Barbaros Boulevard."',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E7E6C),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
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
          'Voice Navigation',
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
        child: Stack(
          children: [
            // ── Full Screen Interactive Map Backdrop ──
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: _initialPosition,
                onMapCreated: (controller) => _mapController = controller,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                mapType: _mapType,
                trafficEnabled: _trafficEnabled,
              ),
            ),

            // ── Left Side Map Layer Controls ──
            Positioned(
              left: 14,
              top: 14,
              child: Column(
                children: [
                  _buildCircleControl(
                    icon: Icons.view_in_ar,
                    isActive: _is3DView,
                    onTap: () {
                      setState(() {
                        _is3DView = !_is3DView;
                        if (_is3DView) {
                          _mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              const CameraPosition(
                                target: LatLng(41.0438, 29.0067),
                                zoom: 15.0,
                                tilt: 45.0,
                              ),
                            ),
                          );
                        } else {
                          _mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              const CameraPosition(
                                target: LatLng(41.0438, 29.0067),
                                zoom: 14.2,
                                tilt: 0.0,
                              ),
                            ),
                          );
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildCircleControl(
                    icon: Icons.language,
                    isActive: _mapType == MapType.hybrid,
                    onTap: () {
                      setState(() {
                        _mapType = _mapType == MapType.normal
                            ? MapType.hybrid
                            : MapType.normal;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildCircleControl(
                    icon: Icons.traffic,
                    isActive: _trafficEnabled,
                    onTap: () {
                      setState(() {
                        _trafficEnabled = !_trafficEnabled;
                      });
                    },
                  ),
                ],
              ),
            ),

            // ── Right Side Navigation Zoom Controls ──
            Positioned(
              right: 14,
              top: 14,
              child: Column(
                children: [
                  _buildCircleControl(
                    icon: Icons.add,
                    onTap: () {
                      _mapController?.animateCamera(CameraUpdate.zoomIn());
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildCircleControl(
                    icon: Icons.remove,
                    onTap: () {
                      _mapController?.animateCamera(CameraUpdate.zoomOut());
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildCircleControl(
                    icon: Icons.my_location,
                    iconColor: const Color(0xFF1E7E6C),
                    onTap: () async {
                      if (_isLoading) return;
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        final coords = await LocationService.getCurrentLocation();
                        final address = await _fetchAddress(coords);
                        if (mounted) {
                          setState(() {
                            _currentLatLng = coords;
                            if (address != null) {
                              _currentAddress = address;
                            } else {
                              _currentAddress = 'Lat: ${coords.latitude.toStringAsFixed(4)}, Lng: ${coords.longitude.toStringAsFixed(4)}';
                            }
                            _isLoading = false;
                          });
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLng(coords),
                          );
                        }
                      } catch (e) {
                        debugPrint('Error getting current location: $e');
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            // ── Simulated Voice Guidance Speech Bubble Overlay ──
            if (_voiceGuidanceActive)
              Positioned(
                top: 200,
                left: 32,
                right: 32,
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.9 + (value * 0.1),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0E2A).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.volume_up, color: Color(0xFF2EA690), size: 28),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Voice Guidance Active',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF2EA690),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'In 300 meters, turn right onto Barbaros Boulevard.',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── GPS Bottom Details Panel ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location pin and address row
                    Row(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _isLoading
                                  ? const Text(
                                      'Fetching location...',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF888888),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    )
                                  : Text(
                                      _currentAddress,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111111),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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

                    const SizedBox(height: 20),

                    // Start Navigation Large Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _toggleVoiceNavigation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E7E6C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _voiceGuidanceActive ? 'Stop Navigation' : 'Start Navigation',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating Circle map controller helper widget
  Widget _buildCircleControl({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    Color iconColor = const Color(0xFF111111),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E7E6C) : Colors.white,
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
          color: isActive ? Colors.white : iconColor,
          size: 22,
        ),
      ),
    );
  }
}
