// lib/find_distance_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FindDistanceScreen extends StatefulWidget {
  const FindDistanceScreen({super.key});

  @override
  State<FindDistanceScreen> createState() => _FindDistanceScreenState();
}

class _FindDistanceScreenState extends State<FindDistanceScreen> {
  GoogleMapController? _mapController;
  final Color _primaryColor = const Color(0xFF1E7E6C);

  // Default camera position: Beşiktaş, Istanbul
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.0438, 29.0067),
    zoom: 13.0,
  );

  // Search input controllers
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  LatLng? _startLatLng;
  LatLng? _endLatLng;

  String _startAddress = 'Select start location on map';
  String _endAddress = 'Select destination on map';

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  double? _calculatedDistanceKm;
  String _estimatedTime = '';

  // Preset location database to resolve simple search queries
  final Map<String, LatLng> _presets = {
    'rawalpindi': const LatLng(33.5973, 73.0679),
    'islamabad': const LatLng(33.6844, 73.0479),
    'lahore': const LatLng(31.5204, 74.3587),
    'besiktas': const LatLng(41.0438, 29.0067),
    'tokyo': const LatLng(35.6762, 139.6503),
    'new york': const LatLng(40.7128, -74.0060),
    'london': const LatLng(51.5074, -0.1278),
    'paris': const LatLng(48.8566, 2.3522),
    'istanbul': const LatLng(41.0082, 28.9784),
  };

  void _onMapTapped(LatLng pos) {
    setState(() {
      if (_startLatLng == null) {
        // Set starting point
        _startLatLng = pos;
        _startAddress = 'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}';
        _startController.text = _startAddress;
        _addMarker('start', pos, 'Starting Point', BitmapDescriptor.hueRed);
        _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
      } else if (_endLatLng == null) {
        // Set ending point
        _endLatLng = pos;
        _endAddress = 'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}';
        _endController.text = _endAddress;
        _addMarker('end', pos, 'Destination Point', BitmapDescriptor.hueBlue);
        _computeDistanceRoute();
      } else {
        // Reset and set new starting point
        _startLatLng = pos;
        _startAddress = 'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}';
        _startController.text = _startAddress;
        _endLatLng = null;
        _endAddress = 'Select destination on map';
        _endController.clear();
        _polylines.clear();
        _calculatedDistanceKm = null;
        _estimatedTime = '';
        _markers.clear();
        _addMarker('start', pos, 'Starting Point', BitmapDescriptor.hueRed);
        _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
      }
    });
  }

  void _addMarker(String id, LatLng pos, String title, double hue) {
    _markers.add(
      Marker(
        markerId: MarkerId(id),
        position: pos,
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(title: title),
      ),
    );
  }

  void _computeDistanceRoute() {
    if (_startLatLng == null || _endLatLng == null) return;

    final start = _startLatLng!;
    final end = _endLatLng!;

    // 1. Calculate Geodesic Distance via Haversine Formula
    const double p = 0.017453292519943295; // pi / 180
    final double a = 0.5 -
        math.cos((end.latitude - start.latitude) * p) / 2 +
        math.cos(start.latitude * p) *
            math.cos(end.longitude * p) *
            (1 - math.cos((end.longitude - start.longitude) * p)) /
            2;
    
    final double dist = 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
    
    // 2. Compute Travel Duration at an average speed of 60 km/h
    final double totalHours = dist / 60.0;
    final int hours = totalHours.floor();
    final int minutes = ((totalHours - hours) * 60).round();

    setState(() {
      _calculatedDistanceKm = dist;
      if (hours > 0) {
        _estimatedTime = '$hours hr $minutes min';
      } else {
        _estimatedTime = '$minutes min';
      }

      // Draw polyline connecting them
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_distance'),
          points: [start, end],
          color: _primaryColor,
          width: 5,
          geodesic: true,
        ),
      );
    });

    // Zoom out map to frame both markers beautifully
    _zoomToFitMarkers();
  }

  void _zoomToFitMarkers() {
    if (_startLatLng == null || _endLatLng == null) return;
    
    final start = _startLatLng!;
    final end = _endLatLng!;

    final bounds = LatLngBounds(
      southwest: LatLng(
        math.min(start.latitude, end.latitude),
        math.min(start.longitude, end.longitude),
      ),
      northeast: LatLng(
        math.max(start.latitude, end.latitude),
        math.max(start.longitude, end.longitude),
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80.0), // padding
    );
  }

  void _searchLocation(bool isStart) {
    final String query = (isStart ? _startController.text : _endController.text).trim().toLowerCase();
    if (query.isEmpty) return;

    LatLng? matchedPos;

    // Direct database matching
    if (_presets.containsKey(query)) {
      matchedPos = _presets[query];
    } else {
      // Simulate fallback coordinate offset close to Beşiktaş to keep it aligned
      final double lat = 41.0438 + (query.hashCode % 100) * 0.001 - 0.05;
      final double lng = 29.0067 + ((query.hashCode >> 2) % 100) * 0.001 - 0.05;
      matchedPos = LatLng(lat, lng);
    }

    if (matchedPos != null) {
      final LatLng position = matchedPos;
      setState(() {
        if (isStart) {
          _startLatLng = position;
          _startAddress = isStart ? _startController.text : 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
          _markers.removeWhere((m) => m.markerId.value == 'start');
          _addMarker('start', position, 'Starting Point', BitmapDescriptor.hueRed);
        } else {
          _endLatLng = position;
          _endAddress = !isStart ? _endController.text : 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
          _markers.removeWhere((m) => m.markerId.value == 'end');
          _addMarker('end', position, 'Destination Point', BitmapDescriptor.hueBlue);
        }

        if (_startLatLng != null && _endLatLng != null) {
          _computeDistanceRoute();
        } else {
          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 14.0));
        }
      });
    }
  }

  void _clearAll() {
    setState(() {
      _startLatLng = null;
      _endLatLng = null;
      _startController.clear();
      _endController.clear();
      _startAddress = 'Select start location on map';
      _endAddress = 'Select destination on map';
      _markers.clear();
      _polylines.clear();
      _calculatedDistanceKm = null;
      _estimatedTime = '';
    });
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
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
          'Find Distance',
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
            onPressed: _clearAll,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Google Map Backdrop ──
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: _initialPosition,
                onMapCreated: (controller) => _mapController = controller,
                markers: _markers,
                polylines: _polylines,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                onTap: _onMapTapped,
              ),
            ),

            // ── Top Search Bars Panel ──
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Start Search field
                    Row(
                      children: [
                        const Icon(Icons.radio_button_checked_rounded, color: Colors.red, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _startController,
                            onSubmitted: (_) => _searchLocation(true),
                            decoration: const InputDecoration(
                              hintText: 'Enter start point (e.g. Islamabad)',
                              hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14.5),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF111111)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search_rounded, size: 18, color: Colors.grey),
                          onPressed: () => _searchLocation(true),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: Color(0xFFF3F4F6), thickness: 1.5),
                    
                    // Destination Search field
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _endController,
                            onSubmitted: (_) => _searchLocation(false),
                            decoration: const InputDecoration(
                              hintText: 'Enter destination (e.g. Rawalpindi)',
                              hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14.5),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF111111)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search_rounded, size: 18, color: Colors.grey),
                          onPressed: () => _searchLocation(false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Right Side Zoom Buttons ──
            Positioned(
              right: 16,
              bottom: _calculatedDistanceKm != null ? 190 : 32,
              child: Column(
                children: [
                  _mapControlBtn(
                    const Icon(Icons.add, size: 22, color: Color(0xFF111111)),
                    onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                  ),
                  const SizedBox(height: 10),
                  _mapControlBtn(
                    const Icon(Icons.remove, size: 22, color: Color(0xFF111111)),
                    onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                  ),
                  const SizedBox(height: 10),
                  _mapControlBtn(
                    const Icon(Icons.gps_fixed_rounded, size: 20, color: Color(0xFF111111)),
                    onTap: () {
                      if (_startLatLng != null) {
                        _mapController?.animateCamera(CameraUpdate.newLatLng(_startLatLng!));
                      } else {
                        _mapController?.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
                      }
                    },
                  ),
                ],
              ),
            ),

            // ── Bottom Telemetry Card ──
            if (_calculatedDistanceKm != null)
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL DISTANCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_calculatedDistanceKm!.toStringAsFixed(2)} km',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111111),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: const Color(0xFFE5E7EB),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'EST. TRAVEL TIME',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _estimatedTime,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/voice_navigation',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Navigate Route',
                            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
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

  Widget _mapControlBtn(Widget child, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
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
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
