import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'services/location_service.dart';

class EarthMapScreen extends StatefulWidget {
  const EarthMapScreen({super.key});

  @override
  State<EarthMapScreen> createState() => _EarthMapScreenState();
}

class _EarthMapScreenState extends State<EarthMapScreen> {
  GoogleMapController? _mapController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.0438, 29.0067),
    zoom: 14.2,
  );

  bool _is3DView = false;
  MapType _mapType = MapType.normal;
  bool _trafficEnabled = false;

  bool _voiceGuidanceActive = false;
  String _currentAddress = 'Location here, Rawalpindi, Pakistan';
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleVoiceNavigation() {
    setState(() {
      _voiceGuidanceActive = !_voiceGuidanceActive;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_voiceGuidanceActive ? Icons.navigation_rounded : Icons.navigation_outlined, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _voiceGuidanceActive
                    ? 'Navigation simulation started!'
                    : 'Navigation simulation stopped!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E7E6C),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _currentAddress = query;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Focused map on "$query"'),
        backgroundColor: const Color(0xFF1E7E6C),
        behavior: SnackBarBehavior.floating,
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
          '3D Earth Map',
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

            // ── Floating Search Location Bar ──
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
                      color: Colors.black12,
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

            // ── Left Side Map Layer Controls (Elevated above details panel) ──
            Positioned(
              left: 14,
              bottom: 180,
              child: Column(
                children: [
                  _buildCircleControl(
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
                    isActive: _is3DView,
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _is3DView ? Colors.white : const Color(0xFF111111),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '3D',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _is3DView ? Colors.white : const Color(0xFF111111),
                        ),
                      ),
                    ),
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

            // ── Right Side Navigation Zoom Controls (Elevated above details panel) ──
            Positioned(
              right: 14,
              bottom: 180,
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
                    icon: Icons.gps_fixed_rounded,
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
                          _currentAddress = 'Location here, Rawalpindi, Pakistan';
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            // ── Bottom Details Card Panel ──
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
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF1F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFFE53935),
                            size: 22,
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
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Color(0xFF111111),
                            size: 22,
                          ),
                          onPressed: _shareLocation,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Start Navigation Large Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _toggleVoiceNavigation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E7E6C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
    IconData? icon,
    Widget? child,
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
        child: Center(
          child: child ?? Icon(
            icon,
            color: isActive ? Colors.white : iconColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}
