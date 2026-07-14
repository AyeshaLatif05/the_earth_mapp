// lib/screens/meet_in_middle_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'services/location_service.dart';

class MeetInMiddleScreen extends StatefulWidget {
  const MeetInMiddleScreen({super.key});

  @override
  State<MeetInMiddleScreen> createState() => _MeetInMiddleScreenState();
}

class _MeetInMiddleScreenState extends State<MeetInMiddleScreen> {
  GoogleMapController? _mapController;
  bool _isRouteSelected = false;
  Set<Polyline> _polylines = {};
  bool _is3DView = false;
  MapType _mapType = MapType.normal;
  bool _trafficEnabled = false;

// ── Add this method inside _MeetInMiddleScreenState ──

void _showSelectRouteSheet() {
  final bool canPopMain = Navigator.canPop(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => _SelectRouteSheet(
      canPopMain: canPopMain,
      onRouteSelected: () {
        setState(() {
          _isRouteSelected = true;
          _setMarkersWithRoute();
        });
      },
    ),
  );
}
  // Default camera position (can be dynamic later)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.0438, 29.0067), // Besiktas, Istanbul (from screenshot)
    zoom: 13.5,
  );

  String _personALocation = 'Location here, Rawalpindi, Pakistan';
  String _personBLocation = 'Location here, Rawalpindi, Pakistan';

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setMarkers();
  }

  void _setMarkers() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('personA'),
          position: const LatLng(41.0438, 29.0067),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Person A'),
        ),
        Marker(
          markerId: const MarkerId('personB'),
          position: const LatLng(41.0300, 28.9900),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Person B'),
        ),
      };
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setMarkersWithRoute() {
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: const [
            LatLng(41.0438, 29.0067),
            LatLng(41.0380, 29.0000),
            LatLng(41.0300, 28.9900),
          ],
          color: const Color(0xFF1A7A68),
          width: 5,
        ),
      };
    });
  }

  void _clearRoute() {
    setState(() {
      _polylines = {};
    });
  }

  void _onStartNavigation() {
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {'showUpdateDialog': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Full screen map ──
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: _initialPosition,
                onMapCreated: (controller) => _mapController = controller,
                markers: _markers,
                polylines: _polylines,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                trafficEnabled: _trafficEnabled,
                mapType: _mapType,
              ),
            ),

            // ── Top AppBar ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(),
            ),

            // ── Map Control Buttons (left side) ──
            Positioned(
              left: 12,
              top: 80,
              child: _buildLeftControls(),
            ),

            // ── Zoom + Location Buttons (right side) ──
            Positioned(
              right: 12,
              top: 80,
              child: _buildRightControls(),
            ),

            // ── Bottom Sheet Panel ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111111)),
            onPressed: () {
              if (_isRouteSelected) {
                setState(() {
                  _isRouteSelected = false;
                  _clearRoute();
                });
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
          const Expanded(
            child: Text(
              'Meet in Middle',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
                letterSpacing: -0.2,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF111111)),
            onPressed: () {
              setState(() {
                _isRouteSelected = false;
                _clearRoute();
                _setMarkers();
                _personALocation = 'Location here, Rawalpindi, Pakistan';
                _personBLocation = 'Location here, Rawalpindi, Pakistan';
              });
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(_initialPosition),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session reset successfully'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeftControls() {
    return Column(
      children: [
        _mapControlBtn(
          Icons.view_in_ar_outlined,
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
                      zoom: 13.5,
                      tilt: 0.0,
                    ),
                  ),
                );
              }
            });
          },
        ),
        const SizedBox(height: 8),
        _mapControlBtn(
          Icons.language,
          isActive: _mapType == MapType.hybrid,
          onTap: () {
            setState(() {
              _mapType = _mapType == MapType.normal ? MapType.hybrid : MapType.normal;
            });
          },
        ),
        const SizedBox(height: 8),
        _mapControlBtn(
          Icons.traffic_outlined,
          isActive: _trafficEnabled,
          onTap: () {
            setState(() {
              _trafficEnabled = !_trafficEnabled;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRightControls() {
    return Column(
      children: [
        _mapControlBtn(Icons.add, onTap: () {
          _mapController?.animateCamera(CameraUpdate.zoomIn());
        }),
        const SizedBox(height: 8),
        _mapControlBtn(Icons.remove, onTap: () {
          _mapController?.animateCamera(CameraUpdate.zoomOut());
        }),
        const SizedBox(height: 8),
        _mapControlBtn(
          Icons.my_location,
          iconColor: const Color(0xFF1A7A68),
          onTap: () async {
            final navigator = Navigator.of(context);
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1A7A68),
                ),
              ),
            );

            try {
              final coords = await LocationService.getCurrentLocation();
              if (!mounted) return;
              navigator.pop(); // Dismiss loading dialog
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(coords),
              );
              setState(() {
                _personALocation = 'My Location (Lat: ${coords.latitude.toStringAsFixed(4)}, Lng: ${coords.longitude.toStringAsFixed(4)})';
                _markers = {
                  Marker(
                    markerId: const MarkerId('personA'),
                    position: coords,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    infoWindow: const InfoWindow(title: 'Person A (You)'),
                  ),
                  Marker(
                    markerId: const MarkerId('personB'),
                    position: const LatLng(41.0300, 28.9900),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                    infoWindow: const InfoWindow(title: 'Person B'),
                  ),
                };
              });
            } catch (e) {
              if (!mounted) return;
              navigator.pop(); // Dismiss loading dialog
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Could not get current location: $e')),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _mapControlBtn(
    IconData icon, {
    VoidCallback? onTap,
    bool isActive = false,
    Color iconColor = const Color(0xFF111111),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A7A68) : Colors.white,
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
          size: 20,
          color: isActive ? Colors.white : iconColor,
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
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
        children: [
          _locationRow(
            label: 'Person A Location',
            address: _personALocation,
            dotColor: const Color(0xFFE53935), // red dot
            onCopy: () => _copyToClipboard(_personALocation),
          ),
          const SizedBox(height: 16),
          _locationRow(
            label: 'Person B Location',
            address: _personBLocation,
            dotColor: const Color(0xFF1A7A68), // teal/blue dot
            onCopy: () => _copyToClipboard(_personBLocation),
          ),
          const SizedBox(height: 20),
          _buildStartNavigationButton(),
        ],
      ),
    );
  }

  Widget _locationRow({
    required String label,
    required String address,
    required Color dotColor,
    required VoidCallback onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, color: dotColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                address,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111111),
                  height: 1.4,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 20, color: Color(0xFF6B7280)),
              onPressed: onCopy,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  // ── Replace _buildStartNavigationButton() with this ──

Widget _buildStartNavigationButton() {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: _isRouteSelected ? _onStartNavigation : _showSelectRouteSheet,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A7A68),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      child: Text(
        _isRouteSelected ? 'Start Navigation' : 'Mark Location in Middle',
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
  );
}

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// ── Add this as a separate widget at the bottom of the file ──

class _SelectRouteSheet extends StatelessWidget {
  final bool canPopMain;
  final VoidCallback onRouteSelected;
  const _SelectRouteSheet({
    required this.canPopMain,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──
          const Text(
            'Select Route',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),

          // ── Subtitle ──
          const Text(
            'Select the route to draw from you want to move to the middle point',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // ── Route Buttons Row ──
          Row(
            children: [
              // Route to Person A — pink/red
              Expanded(
                child: _RouteButton(
                  label: 'Route to Person A',
                  backgroundColor: const Color(0xFFFF8A8A),
                  textColor: const Color(0xFF1A0000),
                  onTap: () {
                    Navigator.pop(context);
                    onRouteSelected();
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Route to Person B — blue
              Expanded(
                child: _RouteButton(
                  label: 'Route to Person B',
                  backgroundColor: const Color(0xFF90B4F5),
                  textColor: const Color(0xFF0A1A40),
                  onTap: () {
                    Navigator.pop(context);
                    onRouteSelected();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reusable route button ──

class _RouteButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _RouteButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}