// lib/street_view_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StreetViewScreen extends StatefulWidget {
  const StreetViewScreen({super.key});

  @override
  State<StreetViewScreen> createState() => _StreetViewScreenState();
}

class _StreetViewScreenState extends State<StreetViewScreen> {
  GoogleMapController? _mapController;
  bool _isFullscreen = false;
  String _placeName = 'Place Name Here';

  // Current camera/marker position: Beşiktaş, Istanbul (mockup matching)
  static const LatLng _besiktasLatLng = LatLng(41.0438, 29.0067);
  LatLng _currentLocation = _besiktasLatLng;
  final Set<Marker> _markers = {};

  // Unsplash panoramic street view image URLs that change depending on selected coordinates to simulate travel!
  final List<String> _panoramas = [
    'https://images.unsplash.com/photo-1542051841857-5f90071e7989?w=1200&auto=format&fit=crop&q=80', // Japan Tokyo Street (Mockup matching crosswalk)
    'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=1200&auto=format&fit=crop&q=80', // Cyberpunk Street
    'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=1200&auto=format&fit=crop&q=80', // European Street
    'https://images.unsplash.com/photo-1514924013511-28c9ffe47cc6?w=1200&auto=format&fit=crop&q=80', // Historic Street
  ];

  int _selectedPanoramaIndex = 0;

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: const MarkerId('street_view_pos'),
        position: _besiktasLatLng,
        infoWindow: const InfoWindow(title: 'Street View Camera'),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('locationName')) {
      final name = args['locationName'] as String;
      if (name != _placeName && name.isNotEmpty) {
        _placeName = name;
        LatLng locationCoords = _besiktasLatLng;
        
        // Lookup coordinate of target cities
        final lowerName = name.toLowerCase();
        if (lowerName.contains('new york')) {
          locationCoords = const LatLng(40.7128, -74.0060);
        } else if (lowerName.contains('london')) {
          locationCoords = const LatLng(51.5074, -0.1278);
        } else if (lowerName.contains('paris')) {
          locationCoords = const LatLng(48.8566, 2.3522);
        } else if (lowerName.contains('tokyo')) {
          locationCoords = const LatLng(35.6762, 139.6503);
        } else if (lowerName.contains('istanbul')) {
          locationCoords = const LatLng(41.0082, 28.9784);
        } else if (lowerName.contains('my location')) {
          locationCoords = const LatLng(37.4275, -122.1697); // Palo Alto Googleplex
        } else {
          // Fallback hash-based coordinate simulation
          final double lat = 41.0438 + (name.hashCode % 1000) / 10000.0 - 0.05;
          final double lng = 29.0067 + ((name.hashCode >> 2) % 1000) / 10000.0 - 0.05;
          locationCoords = LatLng(lat, lng);
        }
        
        _currentLocation = locationCoords;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('street_view_pos'),
            position: _currentLocation,
            infoWindow: InfoWindow(
              title: _placeName,
              snippet: 'Lat: ${_currentLocation.latitude.toStringAsFixed(4)}, Lng: ${_currentLocation.longitude.toStringAsFixed(4)}',
            ),
          ),
        );
        
        _selectedPanoramaIndex = name.hashCode.abs() % _panoramas.length;
      }
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _currentLocation = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('street_view_pos'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Street View Position',
            snippet: 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
          ),
        ),
      );
      
      // Update street view context to simulate real movement
      _selectedPanoramaIndex = (position.latitude.hashCode + position.longitude.hashCode) % _panoramas.length;
      
      if (_selectedPanoramaIndex == 0) {
        _placeName = 'Place Name Here';
      } else if (_selectedPanoramaIndex == 1) {
        _placeName = 'Istanbul City Center';
      } else if (_selectedPanoramaIndex == 2) {
        _placeName = 'Yıldız Palace Road';
      } else {
        _placeName = 'Ortaköy Pier Street';
      }
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.account_balance_rounded, color: Color(0xFF1E8278)),
            const SizedBox(width: 10),
            Text(
              _placeName == 'Place Name Here' ? 'Landmark Info' : _placeName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'This is a simulated high-fidelity interactive Street View of ${_placeName == 'Place Name Here' ? 'Beşiktaş district in Istanbul' : _placeName}. Drag the top panorama view left or right to explore your surroundings, and tap different locations on the map below to move around.',
          style: const TextStyle(fontSize: 15, height: 1.45, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF1E8278), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _isFullscreen
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leadingWidth: 48,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                    size: 22,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              title: const Text(
                'Street View',
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
        child: Column(
          children: [
            // ── TOP HALF: Interactive Panorama ──
            Expanded(
              flex: _isFullscreen ? 100 : 52,
              child: Stack(
                children: [
                  // Scrollable Panorama Image (Allows horizontal panning!)
                  Positioned.fill(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      // Center the starting scroll position
                      controller: ScrollController(initialScrollOffset: 300),
                      child: Image.network(
                        _panoramas[_selectedPanoramaIndex],
                        height: double.infinity,
                        width: 1400, // Oversized to allow sliding pan effect
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFFE5E7EB),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1E8278),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Black semi-translucent location name capsule at bottom center
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _placeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Floating Circle Control Buttons on the right side
                  Positioned(
                    right: 16,
                    bottom: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Monument/Museum button
                        _buildCircleBtn(
                          icon: Icons.account_balance_rounded,
                          onTap: _showInfoDialog,
                        ),
                        const SizedBox(height: 12),
                        // Fullscreen toggle button
                        _buildCircleBtn(
                          icon: _isFullscreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                          onTap: () {
                            setState(() {
                              _isFullscreen = !_isFullscreen;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Floating Back Button in Fullscreen mode
                  if (_isFullscreen)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFullscreen = false;
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── BOTTOM HALF: Interactive Google Map ──
            if (!_isFullscreen)
              Expanded(
                flex: 48,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                    ),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation,
                      zoom: 14.5,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
                    markers: _markers,
                    onTap: _onMapTapped,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF111111),
          size: 24,
        ),
      ),
    );
  }
}
