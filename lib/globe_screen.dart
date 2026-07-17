import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'services/location_service.dart';

class GlobeScreen extends StatefulWidget {
  const GlobeScreen({super.key});

  @override
  State<GlobeScreen> createState() => _GlobeScreenState();
}

class _GlobeScreenState extends State<GlobeScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  
  MapType _mapType = MapType.satellite;
  bool _isLoading = false;
  LatLng _mapCenter = const LatLng(0.0, 0.0); // Center of the Earth view
  final Set<Marker> _markers = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _recenterGPS() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final coords = await LocationService.getCurrentLocation();
      setState(() {
        _mapCenter = coords;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('my_pos'),
            position: coords,
            infoWindow: const InfoWindow(title: 'My Location'),
          ),
        );
        _isLoading = false;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(coords, 14.0),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not retrieve current location')),
      );
    }
  }

  void _onSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
    });

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
            final target = LatLng(lat, lon);
            setState(() {
              _mapCenter = target;
              _markers.clear();
              _markers.add(
                Marker(
                  markerId: const MarkerId('search_pos'),
                  position: target,
                  infoWindow: InfoWindow(title: query),
                ),
              );
              _isLoading = false;
            });
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(target, 12.0),
            );
            return;
          }
        }
      }
      throw Exception('Location not found');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not find location: $query')),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '3D Globe',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // ── Real Earth Map View ──
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _mapCenter,
                zoom: 2.2, // Zoomed out to show the earth like a globe
              ),
              mapType: _mapType,
              markers: _markers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) => _mapController = controller,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                  if (_isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E7E6C)),
                    ),
                ],
              ),
            ),
          ),

          // ── Left Side Control Button (Map Type Selector) ──
          Positioned(
            left: 16,
            bottom: 24,
            child: _buildCircleControl(
              icon: Icons.layers_outlined,
              onTap: () {
                setState(() {
                  _mapType = _mapType == MapType.satellite
                      ? MapType.hybrid
                      : _mapType == MapType.hybrid
                          ? MapType.normal
                          : MapType.satellite;
                });
              },
            ),
          ),

          // ── Zoom & Recenter Control Column ──
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCircleControl(
                  icon: Icons.add,
                  onTap: _zoomIn,
                ),
                const SizedBox(height: 10),
                _buildCircleControl(
                  icon: Icons.remove,
                  onTap: _zoomOut,
                ),
                const SizedBox(height: 10),
                _buildCircleControl(
                  icon: Icons.gps_fixed_rounded,
                  iconColor: const Color(0xFF1E7E6C),
                  onTap: _recenterGPS,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleControl({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF111111),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
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
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
    );
  }
}
