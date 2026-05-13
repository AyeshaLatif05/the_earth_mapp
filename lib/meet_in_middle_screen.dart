// lib/screens/meet_in_middle_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MeetInMiddleScreen extends StatefulWidget {
  const MeetInMiddleScreen({super.key});

  @override
  State<MeetInMiddleScreen> createState() => _MeetInMiddleScreenState();
}

class _MeetInMiddleScreenState extends State<MeetInMiddleScreen> {
  GoogleMapController? _mapController;
// ── Add this method inside _MeetInMiddleScreenState ──

void _showSelectRouteSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => const _SelectRouteSheet(),
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

  void _onStartNavigation() {
    // TODO: Launch navigation logic
    // e.g. open Google Maps with midpoint coordinates
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
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                trafficEnabled: false,
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
            onPressed: () => Navigator.pop(context),
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
              // TODO: Clear/delete this session
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeftControls() {
    return Column(
      children: [
        _mapControlBtn(Icons.view_in_ar_outlined, onTap: () {
          // Toggle 3D view
        }),
        const SizedBox(height: 8),
        _mapControlBtn(Icons.language, onTap: () {
          // Toggle map type
        }),
        const SizedBox(height: 8),
        _mapControlBtn(Icons.traffic_outlined, onTap: () {
          // Toggle traffic
        }),
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
          onTap: () {
            // Center on user location
          },
        ),
      ],
    );
  }

  Widget _mapControlBtn(
    IconData icon, {
    VoidCallback? onTap,
    Color iconColor = const Color(0xFF111111),
  }) {
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
        child: Icon(icon, size: 20, color: iconColor),
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
      onPressed: _showSelectRouteSheet, // <-- now opens the sheet
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A7A68),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Mark Location in Middle',
        style: TextStyle(
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
  const _SelectRouteSheet();

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
                    // TODO: Draw route to Person A
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
                    // TODO: Draw route to Person B
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