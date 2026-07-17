import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'services/location_service.dart';

class TrafficFinderScreen extends StatefulWidget {
  const TrafficFinderScreen({super.key});

  @override
  State<TrafficFinderScreen> createState() => _TrafficFinderScreenState();
}

class _TrafficFinderScreenState extends State<TrafficFinderScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  
  MapType _currentMapType = MapType.normal;
  bool _isLoading = false;
  LatLng _mapCenter = const LatLng(41.0438, 29.0067); // Default Beşiktaş, Istanbul
  final Set<Marker> _markers = {};

  // Traffic legend items
  final List<_TrafficLabel> _labels = const [
    _TrafficLabel(label: 'Normal', color: Color(0xFF2ECC40)),
    _TrafficLabel(label: 'Slow', color: Color(0xFFFFBB00)),
    _TrafficLabel(label: 'Slower', color: Color(0xFFFF7700)),
    _TrafficLabel(label: 'Heavy', color: Color(0xFFCC2200)),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCurrentLocation() async {
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
            markerId: const MarkerId('current_pos'),
            position: _mapCenter,
            infoWindow: const InfoWindow(title: 'You are here'),
          ),
        );
        _isLoading = false;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_mapCenter, 15.0),
      );
    } catch (e) {
      debugPrint('Error fetching current location in traffic screen: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

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
              CameraUpdate.newLatLngZoom(target, 15.0),
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Traffic Finder',
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
          // ── Map view ──
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _mapCenter,
                zoom: 14.5,
              ),
              trafficEnabled: true,
              mapType: _currentMapType,
              markers: _markers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) => _mapController = controller,
            ),
          ),

          // ── Search bar ──
          Positioned(
            top: 12,
            left: 14,
            right: 14,
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
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _searchLocation(),
                decoration: InputDecoration(
                  hintText: 'Search your location',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF1E7E6C)),
                    onPressed: _searchLocation,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Loading Indicator overlay
          if (_isLoading)
            const Positioned(
              top: 75,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E7E6C)),
                        ),
                        SizedBox(width: 12),
                        Text('Updating map...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Left side map controls ───────────────────────────────────────
          Positioned(
            left: 14,
            bottom: 80,
            child: Column(
              children: [
                _MapControlBtn(
                  icon: Icons.layers_outlined,
                  onTap: () {
                    setState(() {
                      _currentMapType = _currentMapType == MapType.normal
                          ? MapType.hybrid
                          : MapType.normal;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _MapControlBtn(
                  icon: Icons.my_location_rounded,
                  onTap: _loadCurrentLocation,
                ),
              ],
            ),
          ),

          // ── Right side zoom controls ────────────────────────────────────
          Positioned(
            right: 14,
            bottom: 80,
            child: Column(
              children: [
                _MapControlBtn(
                  icon: Icons.add,
                  onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                ),
                const SizedBox(height: 10),
                _MapControlBtn(
                  icon: Icons.remove,
                  onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                ),
              ],
            ),
          ),

          // ── Traffic legend bar ──────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: _labels
                    .map((t) => Expanded(child: _TrafficLegendBtn(item: t)))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapControlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
        child: Icon(icon, color: const Color(0xFF111111), size: 22),
      ),
    );
  }
}

class _TrafficLegendBtn extends StatelessWidget {
  final _TrafficLabel item;

  const _TrafficLegendBtn({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 8,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
    );
  }
}

class _TrafficLabel {
  final String label;
  final Color color;

  const _TrafficLabel({required this.label, required this.color});
}
