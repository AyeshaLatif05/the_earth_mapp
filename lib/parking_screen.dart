// lib/screens/parking_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'services/firebase_service.dart';
import 'services/location_service.dart';

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  GoogleMapController? _mapController;
  bool _trafficEnabled = false;
  MapType _currentMapType = MapType.normal;
  LatLng? _parkedLocation;
  bool _isLoading = false;

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

  Future<LatLng?> _searchGeocode(String query) async {
    try {
      final searchUri = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
      final headers = {'User-Agent': 'LiveEarthMap/1.0 (contact@example.com)'};
      final response = await http.get(searchUri, headers: headers).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat']?.toString() ?? '');
          final lon = double.tryParse(data[0]['lon']?.toString() ?? '');
          if (lat != null && lon != null) {
            return LatLng(lat, lon);
          }
        }
      }
    } catch (e) {
      debugPrint('Error searching geocode: $e');
    }
    return null;
  }

  void _onMapTapped(LatLng position) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: position,
          infoWindow: const InfoWindow(title: 'Selected Location'),
        ),
      );
      if (_parkedLocation != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('parked_location'),
            position: _parkedLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'Your Parked Car'),
          ),
        );
      }
    });

    final address = await _fetchAddress(position);

    if (mounted) {
      setState(() {
        if (address != null) {
          _currentAddress = address;
        } else {
          _currentAddress = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
        }
        _isLoading = false;
      });
    }
  }

  void _saveParkingSpot() async {
    final currentMarker = _markers.firstWhere(
      (m) => m.markerId.value == 'current_location',
      orElse: () => const Marker(markerId: MarkerId('')),
    );

    if (currentMarker.markerId.value.isEmpty) return;

    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Save Parking',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter parking name',
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1E8278)),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final String enteredName = nameController.text.trim();
                        Navigator.pop(context);
                        _performSaveParkingSpot(
                          enteredName.isNotEmpty ? enteredName : 'Parked Spot',
                          _currentAddress,
                          currentMarker.position.latitude,
                          currentMarker.position.longitude,
                          currentMarker.position,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E8278),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performSaveParkingSpot(
    String name,
    String location,
    double latitude,
    double longitude,
    LatLng position,
  ) async {
    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1E8278),
        ),
      ),
    );

    try {
      await FirebaseService.instance.saveParkingSpot(
        name: name,
        location: location,
        latitude: latitude,
        longitude: longitude,
      );
      if (mounted) Navigator.pop(context); // Dismiss loading spinner
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading spinner
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save parking spot: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _parkedLocation = position;
      _markers.add(
        Marker(
          markerId: const MarkerId('parked_location'),
          position: _parkedLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Parked Car'),
        ),
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Parking spot saved successfully!',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E8278),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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

  void _searchLocation() async {
    if (_isLoading) return;
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final newPos = await _searchGeocode(query);

    if (newPos != null) {
      final address = await _fetchAddress(newPos);
      if (mounted) {
        setState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: newPos,
              infoWindow: InfoWindow(title: query),
            ),
          );
          if (_parkedLocation != null) {
            _markers.add(
              Marker(
                markerId: const MarkerId('parked_location'),
                position: _parkedLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                infoWindow: const Icon(Icons.directions_car) as InfoWindow, // fallback representation matching code
              ),
            );
          }
          if (address != null) {
            _currentAddress = address;
          } else {
            _currentAddress = query;
          }
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(newPos),
        );
      }
    } else {
      final fallbackPos = LatLng(
        41.0438 + (query.hashCode % 100) * 0.0001,
        29.0067 + (query.hashCode % 50) * 0.0001,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not locate address. Showing simulated location.')),
        );
        setState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: fallbackPos,
              infoWindow: InfoWindow(title: query),
            ),
          );
          if (_parkedLocation != null) {
            _markers.add(
              Marker(
                markerId: const MarkerId('parked_location'),
                position: _parkedLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                infoWindow: const InfoWindow(title: 'Your Parked Car'),
              ),
            );
          }
          _currentAddress = query;
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(fallbackPos),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111111)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Parking',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Color(0xFF111111)),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/saved_parkings');
              if (result != null && result is Map<String, dynamic>) {
                final name = result['name'] ?? 'Parking Spot';
                final address = result['location'] ?? '';
                
                final double lat = (result['latitude'] as num?)?.toDouble() ?? 41.0438;
                final double lng = (result['longitude'] as num?)?.toDouble() ?? 29.0067;
                final LatLng newPos = LatLng(lat, lng);
                
                setState(() {
                  _markers.clear();
                  _markers.add(
                    Marker(
                      markerId: MarkerId('parked_${result['id']}'),
                      position: newPos,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      infoWindow: InfoWindow(title: name, snippet: address),
                    ),
                  );
                  _currentAddress = address;
                  _parkedLocation = newPos;
                });
                
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(newPos, 15.5),
                );
              }
            },
          ),
        ],
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
                    if (_isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E8278)),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Left Floating Controls Overlay ──
            Positioned(
              left: 16,
              bottom: 190,
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
              bottom: 190,
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
                    onTap: () async {
                      if (_isLoading) return;
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        final coords = await LocationService.getCurrentLocation();
                        setState(() {
                          _isLoading = false;
                        });
                        _onMapTapped(coords);
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(coords),
                        );
                      } catch (e) {
                        debugPrint('Error getting location: $e');
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            // ── Bottom Location Sheet Panel ──
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
                      'Location',
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
                          Icons.location_on,
                          color: Color(0xFFE53935),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _isLoading
                              ? const Text(
                                  'Fetching location...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF888888),
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : Text(
                                  _currentAddress,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111111),
                                    height: 1.4,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Icons.share_outlined,
                            size: 22,
                            color: Color(0xFF6B7280),
                          ),
                          onPressed: () {
                            // Trigger native copy / share action
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveParkingSpot,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E8278),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Park Here',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
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
