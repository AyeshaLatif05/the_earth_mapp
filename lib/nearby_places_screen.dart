// lib/nearby_places_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearbyPlacesScreen extends StatefulWidget {
  const NearbyPlacesScreen({super.key});

  @override
  State<NearbyPlacesScreen> createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  // Selected category for the detail map view
  String? _selectedCategory;

  // Mock list of categories matching the mockup precisely
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Airport',
      'icon': Icons.local_airport_rounded,
      'color': const Color(0xFF0288D1), // Cyan/Blue
      'bgColor': const Color(0xFFE1F5FE),
    },
    {
      'name': 'ATM',
      'icon': Icons.local_atm_rounded,
      'color': const Color(0xFF00ACC1), // Teal
      'bgColor': const Color(0xFFE0F7FA),
    },
    {
      'name': 'Bank',
      'icon': Icons.account_balance_rounded,
      'color': const Color(0xFF3F51B5), // Indigo
      'bgColor': const Color(0xFFE8EAF6),
    },
    {
      'name': 'Bar',
      'icon': Icons.local_bar_rounded,
      'color': const Color(0xFFFFB300), // Amber
      'bgColor': const Color(0xFFFFF8E1),
    },
    {
      'name': 'Beauty Salon',
      'icon': Icons.face_retouching_natural_rounded,
      'color': const Color(0xFFEC407A), // Pink
      'bgColor': const Color(0xFFFCE4EC),
    },
    {
      'name': 'Book Store',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF43A047), // Green
      'bgColor': const Color(0xFFE8F5E9),
    },
    {
      'name': 'Bakery',
      'icon': Icons.bakery_dining_rounded,
      'color': const Color(0xFF8D6E63), // Brown
      'bgColor': const Color(0xFFEFEBE9),
    },
    {
      'name': 'Bowling',
      'icon': Icons.sports_baseball_rounded,
      'color': const Color(0xFFE53935), // Red
      'bgColor': const Color(0xFFFFEBEE),
    },
    {
      'name': 'Bus Station',
      'icon': Icons.directions_bus_rounded,
      'color': const Color(0xFFFB8C00), // Orange
      'bgColor': const Color(0xFFFFF3E0),
    },
    {
      'name': 'Cafe',
      'icon': Icons.coffee_rounded,
      'color': const Color(0xFF5D4037), // Dark brown
      'bgColor': const Color(0xFFEFEBE9),
    },
    {
      'name': 'Car Rental',
      'icon': Icons.car_rental_rounded,
      'color': const Color(0xFF5E35B1), // Purple
      'bgColor': const Color(0xFFEDE7F6),
    },
    {
      'name': 'Car Repair',
      'icon': Icons.build_circle_rounded,
      'color': const Color(0xFF455A64), // Blue Grey
      'bgColor': const Color(0xFFECEFF1),
    },
  ];

  // Map markers depending on category selected
  final Map<String, List<Marker>> _categoryMarkers = {
    'Cafe': [
      const Marker(
        markerId: MarkerId('cafe1'),
        position: LatLng(33.6007, 73.0678),
        infoWindow: InfoWindow(title: 'Gloria Jean\'s Coffees', snippet: 'Top Rated Cafe'),
      ),
      const Marker(
        markerId: MarkerId('cafe2'),
        position: LatLng(33.5956, 73.0612),
        infoWindow: InfoWindow(title: 'Second Cup Coffee', snippet: 'Sleek ambiance & study spot'),
      ),
    ],
    'ATM': [
      const Marker(
        markerId: MarkerId('atm1'),
        position: LatLng(33.5978, 73.0654),
        infoWindow: InfoWindow(title: 'HBL 24/7 ATM', snippet: 'Quick cash dispenser'),
      ),
      const Marker(
        markerId: MarkerId('atm2'),
        position: LatLng(33.6023, 73.0712),
        infoWindow: InfoWindow(title: 'Standard Chartered ATM', snippet: 'Secure multi-card ATM'),
      ),
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredCategories() {
    if (_searchQuery.isEmpty) {
      return _categories;
    }
    return _categories
        .where((cat) => cat['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // If a category is selected, render the dynamic Map view instead of the Grid list
    if (_selectedCategory != null) {
      return _buildMapView(_selectedCategory!);
    }

    final filtered = _getFilteredCategories();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Dynamic Premium Header (With search toggle matching mockup) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          size: 36,
                          color: Color(0xFF1F1F1F),
                        ),
                        splashRadius: 24,
                      ),
                      const SizedBox(width: 4),
                      if (!_isSearchExpanded)
                        const Text(
                          'Nearby Places',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F1F1F),
                            letterSpacing: -0.5,
                          ),
                        ),
                    ],
                  ),
                  _isSearchExpanded
                      ? Expanded(
                          child: Container(
                            height: 44,
                            margin: const EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                              autofocus: true,
                              style: const TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Search categories...',
                                border: InputBorder.none,
                                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                      _isSearchExpanded = false;
                                    });
                                  },
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              _isSearchExpanded = true;
                            });
                          },
                          icon: const Icon(
                            Icons.search_rounded,
                            size: 28,
                            color: Color(0xFF1F1F1F),
                          ),
                          splashRadius: 24,
                        ),
                ],
              ),
            ),

            // ── Grid representation of Nearby Place Categories ──
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_rounded, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No categories match "$_searchQuery"',
                            style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final cat = filtered[index];
                        return _buildCategoryCard(cat);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable Category Grid Card ───────────────────────────────────────────
  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = cat['name'] as String;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Category Name Align left bottom-ish
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  cat['name'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    height: 1.2,
                  ),
                ),
              ),
            ),
            // Flat Illustrative Icon aligned right top-ish
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cat['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  cat['icon'] as IconData,
                  color: cat['color'] as Color,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dynamic Map Details View for Category ──────────────────────────────────
  Widget _buildMapView(String category) {
    // Check if we have pre-configured mock location markers for this category
    final markers = _categoryMarkers[category] ??
        [
          Marker(
            markerId: MarkerId('${category.toLowerCase()}Default'),
            position: const LatLng(33.5973, 73.0679),
            infoWindow: InfoWindow(title: 'Nearby $category', snippet: 'Located in Rawalpindi'),
          ),
        ];

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map Background Backdrop ──
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(33.5973, 73.0679),
                zoom: 14.5,
              ),
              markers: Set<Marker>.from(markers),
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
            ),
          ),

          // ── Header Overlay (Tapping returns to grid) ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Nearby $category',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Information Card Drawer ──
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.my_location_rounded, color: Color(0xFF43A047), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Found ${markers.length} spots nearby',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const Text(
                              'Rawalpindi, Pakistan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Directions to the nearest $category loaded.'),
                          backgroundColor: const Color(0xFF1E7E6C),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E7E6C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 0,
                    ),
                    child: const Text('Show Directions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
