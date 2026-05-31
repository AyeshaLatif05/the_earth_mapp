// lib/saved_parkings_screen.dart

import 'package:flutter/material.dart';

class SavedParkingsScreen extends StatefulWidget {
  const SavedParkingsScreen({super.key});

  @override
  State<SavedParkingsScreen> createState() => _SavedParkingsScreenState();
}

class _SavedParkingsScreenState extends State<SavedParkingsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  // Mock list of saved parkings matching the mockup
  final List<Map<String, String>> _allParkings = [
    {
      'id': '1',
      'name': 'Parking Name',
      'location': 'Location here, Rawalpindi, Pakistan',
    },
    {
      'id': '2',
      'name': 'Parking Name',
      'location': 'Location here, Rawalpindi, Pakistan',
    },
    {
      'id': '3',
      'name': 'Centaurus Mall Parking',
      'location': 'F-8, Islamabad, Pakistan',
    },
    {
      'id': '4',
      'name': 'Commercial Market Parking',
      'location': 'Satellite Town, Rawalpindi, Pakistan',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getFilteredParkings() {
    if (_searchQuery.isEmpty) {
      return _allParkings;
    }
    return _allParkings
        .where((p) =>
            p['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p['location']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredParkings = _getFilteredParkings();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        title: _isSearchExpanded
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search parkings...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _isSearchExpanded = false;
                        });
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              )
            : const Text(
                'Saved Parkings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: -0.2,
                ),
              ),
        centerTitle: false,
        actions: [
          if (!_isSearchExpanded)
            IconButton(
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.black,
                size: 26,
              ),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = true;
                });
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: filteredParkings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_parking_rounded,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No saved parkings yet'
                                : 'No results found for "$_searchQuery"',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredParkings.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Color(0xFFF3F4F6),
                        height: 1,
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        final parking = filteredParkings[index];
                        return _buildParkingTile(parking);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingTile(Map<String, String> parking) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Red location pin icon on the left
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on,
              color: Color(0xFFE53935), // Red pin
              size: 28,
            ),
          ),
          const SizedBox(width: 14),

          // Central details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  parking['name']!,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  parking['location']!,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF888888),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Trailing three horizontal lines menu icon
          IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: Color(0xFF111111),
              size: 24,
            ),
            onPressed: () {
              _showOptionsSheet(parking);
            },
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet(Map<String, String> parking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    parking['name']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.map_outlined, color: Color(0xFF1E8278)),
                  title: const Text('Show on Map', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    // Pop saved parking screen and optionally return position to map
                    Navigator.pop(context, parking);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: Color(0xFF1E8278)),
                  title: const Text('Share Location', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied location to clipboard: ${parking['location']}'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text('Delete Parking Spot', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  onTap: () {
                    setState(() {
                      _allParkings.removeWhere((p) => p['id'] == parking['id']);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Parking spot deleted.'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
