// lib/screens/altitude_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AltitudeScreen extends StatefulWidget {
  const AltitudeScreen({super.key});

  @override
  State<AltitudeScreen> createState() => _AltitudeScreenState();
}

class _AltitudeScreenState extends State<AltitudeScreen> {
  GoogleMapController? _mapController;
  bool _trafficEnabled = false;
  MapType _currentMapType = MapType.normal;
  double _currentAltitude = 512.00;

  // Default camera position: Beşiktaş, Istanbul matching mockup
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.0438, 29.0067),
    zoom: 14.5,
  );

  String _currentAddress = 'Location here, Rawalpindi, Pakistan';
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      const Marker(
        markerId: MarkerId('current_location'),
        position: LatLng(41.0438, 29.0067),
        infoWindow: InfoWindow(title: 'Selected Location'),
      ),
    );
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: position,
          infoWindow: const InfoWindow(title: 'Selected Location'),
        ),
      );
      // Simulate real-time altitude based on coordinate hash for realistic variety
      _currentAltitude = 120.0 + (position.latitude.hashCode + position.longitude.hashCode) % 680;
      _currentAddress = 'Location: Lat ${position.latitude.toStringAsFixed(4)}, Lng ${position.longitude.toStringAsFixed(4)}';
    });
  }

  void _toggleTraffic() {
    setState(() {
      _trafficEnabled = !_trafficEnabled;
    });
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _searchLocation() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Simulate geocoding to a random offset near Beşiktaş
    final newPos = LatLng(
      41.0438 + (query.hashCode % 100) * 0.0001,
      29.0067 + (query.hashCode % 50) * 0.0001,
    );

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: newPos,
          infoWindow: InfoWindow(title: query),
        ),
      );
      _currentAltitude = 150.0 + (query.hashCode % 450);
      _currentAddress = query;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(newPos),
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111111)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Altitude Finder',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Interactive Map Background ──
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: _initialPosition,
                onMapCreated: (controller) => _mapController = controller,
                markers: _markers,
                trafficEnabled: _trafficEnabled,
                mapType: _currentMapType,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                onTap: _onMapTapped,
              ),
            ),

            // ── Top Search Location Bar ──
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF6B7280), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _searchLocation(),
                        decoration: const InputDecoration(
                          hintText: 'Search your location',
                          hintStyle: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Left Floating Controls Overlay ──
            Positioned(
              left: 16,
              bottom: 180,
              child: Column(
                children: [
                  _mapControlBtn(
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        '3D',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                    onTap: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: _markers.isNotEmpty
                                ? _markers.first.position
                                : const LatLng(41.0438, 29.0067),
                            zoom: 15.5,
                            tilt: 45,
                            bearing: 30,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _mapControlBtn(
                    Icon(
                      Icons.public,
                      size: 20,
                      color: _currentMapType == MapType.satellite
                          ? const Color(0xFF1E8278)
                          : const Color(0xFF111111),
                    ),
                    onTap: _toggleMapType,
                  ),
                  const SizedBox(height: 10),
                  _mapControlBtn(
                    Icon(
                      Icons.traffic_outlined,
                      size: 20,
                      color: _trafficEnabled
                          ? const Color(0xFF1E8278)
                          : const Color(0xFF111111),
                    ),
                    onTap: _toggleTraffic,
                  ),
                ],
              ),
            ),

            // ── Right Floating Controls Overlay ──
            Positioned(
              right: 16,
              bottom: 180,
              child: Column(
                children: [
                  _mapControlBtn(
                    const Icon(Icons.add, size: 22, color: Color(0xFF111111)),
                    onTap: () {
                      _mapController?.animateCamera(CameraUpdate.zoomIn());
                    },
                  ),
                  const SizedBox(height: 10),
                  _mapControlBtn(
                    const Icon(Icons.remove, size: 22, color: Color(0xFF111111)),
                    onTap: () {
                      _mapController?.animateCamera(CameraUpdate.zoomOut());
                    },
                  ),
                  const SizedBox(height: 10),
                  _mapControlBtn(
                    const Icon(Icons.my_location, size: 20, color: Color(0xFF111111)),
                    onTap: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(_initialPosition),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Bottom Altitude Sheet Panel ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Altitude',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.filter_hdr, // Mountain icon matching terrain
                          color: Color(0xFF1E8278),
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${_currentAltitude.toStringAsFixed(2)} m',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111111),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFFE53935),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF555555),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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

  Widget _mapControlBtn(Widget child, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
