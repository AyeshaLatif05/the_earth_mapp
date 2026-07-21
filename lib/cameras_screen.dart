// lib/cameras_screen.dart

import 'package:flutter/material.dart';
import 'upload_video_dialog.dart';

class CamerasScreen extends StatefulWidget {
  const CamerasScreen({super.key});

  @override
  State<CamerasScreen> createState() => _CamerasScreenState();
}

class _CamerasScreenState extends State<CamerasScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Selection mode variables for the History tab
  bool _isSelectMode = false;
  final Set<String> _selectedHistoryIds = {};

  // Custom height for the bottom navigation bar
  final double _bottomNavBarHeight = 76.0;

  // Mock list of cameras matching both Mockups
  final List<Map<String, dynamic>> _allCameras = [
    {
      'id': '1',
      'name': 'Earth Orbit Stream',
      'imageUrl': 'https://images.unsplash.com/photo-1484406566174-9da000fda645?w=500&auto=format&fit=crop&q=80',
      'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-earth-rotating-in-space-42683-large.mp4',
      'countryCode': 'DE',
      'countryName': 'Germany',
      'flagEmoji': '🇩🇪',
      'isFavorite': false,
      'category': 'Space',
    },
    {
      'id': '2',
      'name': 'Cape Town Beach Stream',
      'imageUrl': 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=500&auto=format&fit=crop&q=80',
      'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-waves-in-the-water-1164-large.mp4',
      'countryCode': 'ZA',
      'countryName': 'South Africa',
      'flagEmoji': '🇿🇦',
      'isFavorite': true,
      'category': 'Beaches',
    },
    {
      'id': '3',
      'name': 'Copenhagen Street Stream',
      'imageUrl': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=500&auto=format&fit=crop&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'countryCode': 'DK',
      'countryName': 'Denmark',
      'flagEmoji': '🇩🇰',
      'isFavorite': false,
      'category': 'European Street',
    },
    {
      'id': '4',
      'name': 'Berlin Traffic Live Cam',
      'imageUrl': 'https://images.unsplash.com/photo-1540959733332-eab4deceeaf7?w=500&auto=format&fit=crop&q=80',
      'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-aerial-view-of-city-traffic-at-night-41547-large.mp4',
      'countryCode': 'DE',
      'countryName': 'Germany',
      'flagEmoji': '🇩🇪',
      'isFavorite': true,
      'category': 'Traffic',
    },
    {
      'id': '5',
      'name': 'Munich Skyline Stream',
      'imageUrl': 'https://images.unsplash.com/photo-1520175480921-4edfa2983e0f?w=500&auto=format&fit=crop&q=80',
      'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-top-aerial-view-of-city-buildings-42691-large.mp4',
      'countryCode': 'DE',
      'countryName': 'Germany',
      'flagEmoji': '🇩🇪',
      'isFavorite': true,
      'category': 'City View',
    },
    {
      'id': '6',
      'name': 'Yosemite National Park Stream',
      'imageUrl': 'https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=500&auto=format&fit=crop&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'countryCode': 'US',
      'countryName': 'United States',
      'flagEmoji': '🇺🇸',
      'isFavorite': true,
      'category': 'Nature',
    },
  ];

  void _openUploadDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const UploadVideoDialog(),
    );
    if (result != null) {
      setState(() {
        _allCameras.insert(0, result);
        _historyCameras.insert(0, result);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added live stream: ${result['name']}')),
        );
      }
    }
  }

  // List of categories for category tab
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Space',
      'count': 1,
      'imageUrl': 'https://images.unsplash.com/photo-1614728894747-a83421e2b9c9?w=500&auto=format&fit=crop&q=80',
    },
    {
      'name': 'City View',
      'count': 2,
      'imageUrl': 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=500&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Beaches',
      'count': 1,
      'imageUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Animals',
      'count': 2,
      'imageUrl': 'https://images.unsplash.com/photo-1484406566174-9da000fda645?w=500&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Nature',
      'count': 3,
      'imageUrl': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Concerts',
      'count': 1,
      'imageUrl': 'https://images.unsplash.com/photo-1506157786151-b8491531f063?w=500&auto=format&fit=crop&q=80',
    },
  ];

  // History list
  final List<Map<String, dynamic>> _historyCameras = [];

  @override
  void initState() {
    super.initState();
    // Pre-populate history stream items matching the Figma history lists
    _historyCameras.add(_allCameras[3]);
    _historyCameras.add(_allCameras[1]);
    _historyCameras.add(_allCameras[5]);
    _historyCameras.add(_allCameras[4]);
  }

  void _toggleFavorite(String id) {
    setState(() {
      final index = _allCameras.indexWhere((cam) => cam['id'] == id);
      if (index != -1) {
        _allCameras[index]['isFavorite'] = !_allCameras[index]['isFavorite'];
      }
    });
  }

  List<Map<String, dynamic>> _getFilteredCameras() {
    if (_searchQuery.isEmpty) {
      return _allCameras;
    }
    return _allCameras
        .where((cam) =>
            cam['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            cam['countryName'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF1A7A68),
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: _openUploadDialog,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Upload Stream', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Dynamic Header ──
            _buildHeader(),

            // ── Main Body Switcher ──
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildCamerasTab(),
                  _buildCategoriesTab(),
                  _buildFavoritesTab(),
                  _buildHistoryTab(),
                ],
                ),
            ),

            // ── Custom Bottom Navigation Bar ──
            _buildCustomBottomNavBar(),
          ],
        ),
      ),
    );
  }

  // ── Dynamic Header Widget ──────────────────────────────────────────────────
  Widget _buildHeader() {
    if (_currentIndex == 0) {
      // 1. Cameras Tab: Search Bar Header Matching Mockup 1
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
        child: Row(
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
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1F1F1F),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search here',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF), size: 18),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _openUploadDialog,
              tooltip: 'Upload Live Stream',
              icon: const Icon(
                Icons.video_call_rounded,
                color: Color(0xFF1A7A68),
                size: 32,
              ),
            ),
          ],
        ),
      );
    }
tentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentIndex == 3 && _isSelectMode) {
      // 2. Selection Mode Header (Specifically for History Tab as shown in Figma)
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSelectMode = false;
                      _selectedHistoryIds.clear();
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    size: 36,
                    color: Color(0xFF1F1F1F),
                  ),
                  splashRadius: 24,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_selectedHistoryIds.length} Selected',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F1F1F),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: _selectedHistoryIds.isEmpty
                  ? null
                  : () {
                      // Delete selected items from history
                      setState(() {
                        _historyCameras.removeWhere(
                          (cam) => _selectedHistoryIds.contains(cam['id']),
                        );
                        _selectedHistoryIds.clear();
                        _isSelectMode = false;
                      });
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Selected items deleted from History.'),
                          backgroundColor: const Color(0xFF1E7E6C),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 28,
                color: _selectedHistoryIds.isEmpty ? const Color(0xFF9CA3AF) : Colors.redAccent,
              ),
              splashRadius: 24,
            ),
          ],
        ),
      );
    } else {
      // 3. Categories, Favorites, and Standard History Header (Mockup 2 & Figma Dropdown)
      String title = '';
      if (_currentIndex == 1) title = 'Categories';
      if (_currentIndex == 2) title = 'Favorites';
      if (_currentIndex == 3) title = 'History';

      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    size: 36,
                    color: Color(0xFF1F1F1F),
                  ),
                  splashRadius: 24,
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F1F1F),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            // PopupMenuButton on right to exactly mirror the Figma menu overlay dropdown!
            _currentIndex == 3
                ? PopupMenuButton<String>(
                    elevation: 8,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    icon: Image.asset(
                      'assets/menu.png',
                      width: 24,
                      height: 24,
                      color: const Color(0xFF1F1F1F),
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.menu_rounded,
                          size: 28,
                          color: Color(0xFF1F1F1F),
                        );
                      },
                    ),
                    onSelected: (value) {
                      if (value == 'select') {
                        setState(() {
                          _isSelectMode = true;
                          _selectedHistoryIds.clear();
                        });
                      } else if (value == 'delete_all') {
                        // Delete all logic
                        setState(() {
                          _historyCameras.clear();
                          _isSelectMode = false;
                          _selectedHistoryIds.clear();
                        });
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('All viewing history cleared.'),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'select',
                        child: Row(
                          children: [
                            Icon(Icons.check_box_outlined, color: Colors.grey[700], size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Select',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete_all',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 12),
                            const Text(
                              'Delete All',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : IconButton(
                    onPressed: () => _showTabMenuOptions(title),
                    icon: Image.asset(
                      'assets/menu.png',
                      width: 24,
                      height: 24,
                      color: const Color(0xFF1F1F1F),
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.menu_rounded,
                          size: 28,
                          color: Color(0xFF1F1F1F),
                        );
                      },
                    ),
                    splashRadius: 24,
                  ),
          ],
        ),
      );
    }
  }

  // ── Show Standard Tab Options Sheet (For Categories/Favorites) ────────────────
  void _showTabMenuOptions(String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title Actions',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 18),
                if (title == 'Favorites') ...[
                  ListTile(
                    leading: const Icon(Icons.heart_broken_outlined, color: Colors.redAccent),
                    title: const Text('Reset All Favorites', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                    onTap: () {
                      setState(() {
                        for (var cam in _allCameras) {
                          cam['isFavorite'] = false;
                        }
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Favorites reset successfully.'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha_rounded, color: Color(0xFF1E7E6C)),
                  title: const Text('Sort Alphabetically'),
                  onTap: () {
                    setState(() {
                      if (title == 'Favorites') {
                        // Custom sort can be processed
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
                  title: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Tab 1: Cameras Grid ────────────────────────────────────────────────────
  Widget _buildCamerasTab() {
    final filteredList = _getFilteredCameras();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No cameras found for "$_searchQuery"',
              style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.82,
      ),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final camera = filteredList[index];
        return _buildCameraCard(camera, isHistoryTab: false);
      },
    );
  }

  Widget _buildCategoriesTab() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 18,
        childAspectRatio: 0.84,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _searchQuery = cat['name'] == 'City View' ? 'South Africa' : cat['name'];
              _searchController.text = _searchQuery;
              _currentIndex = 0; // jump back to camera tab with filtered results
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.015),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            cat['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Text(
                    cat['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Tab 3: Favorites ───────────────────────────────────────────────────────
  Widget _buildFavoritesTab() {
    final favoritesList = _allCameras.where((cam) => cam['isFavorite'] == true).toList();

    if (favoritesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No favorites added yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.82,
      ),
      itemCount: favoritesList.length,
      itemBuilder: (context, index) {
        final camera = favoritesList[index];
        return _buildCameraCard(camera, isHistoryTab: false);
      },
    );
  }

  // ── Tab 4: History Grid (Supports Selection checkboxes from Figma) ─────────
  Widget _buildHistoryTab() {
    if (_historyCameras.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No history recorded yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.82,
      ),
      itemCount: _historyCameras.length,
      itemBuilder: (context, index) {
        final camera = _historyCameras[index];
        return _buildCameraCard(camera, isHistoryTab: true);
      },
    );
  }

  // ── Reusable Grid Stream Card Widget ─────────────────────────────────────────
  Widget _buildCameraCard(Map<String, dynamic> camera, {required bool isHistoryTab}) {
    final isFav = camera['isFavorite'] as bool;
    final id = camera['id'] as String;
    final isSelected = _selectedHistoryIds.contains(id);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image View with Play Overlay
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          camera['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E7E6C)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Play overlay button (Hidden/Disabled in selection mode)
                      if (!(_isSelectMode && isHistoryTab))
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              if (!_historyCameras.any((element) => element['id'] == id)) {
                                setState(() {
                                  _historyCameras.insert(0, camera);
                                });
                              }
                              Navigator.pushNamed(
                                context,
                                '/live_stream_player',
                                arguments: camera,
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Details & Meta info bottom section
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Flags & Heart row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // circular flag emoji wrapper
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: ClipOval(
                              child: Text(
                                camera['flagEmoji'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          // heart icon favoriting (Hidden in select mode)
                          if (!(_isSelectMode && isHistoryTab))
                            GestureDetector(
                              onTap: () => _toggleFavorite(id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFav ? const Color(0xFFFF2D55) : const Color(0xFF9CA3AF),
                                  size: 22,
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 28, height: 28),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Camera Stream Title
                      Text(
                        camera['name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Checkbox Selection Overlay (renders over the top left image area in select mode, matching Figma)
            if (_isSelectMode && isHistoryTab)
              Positioned.fill(
                child: Material(
                  color: isSelected ? const Color(0xFF1E7E6C).withOpacity(0.08) : Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedHistoryIds.remove(id);
                        } else {
                          _selectedHistoryIds.add(id);
                        }
                      });
                    },
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? const Color(0xFF1E7E6C) : Colors.black26,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Custom Height Bottom Navigation Bar Widget ─────────────────────────────
  Widget _buildCustomBottomNavBar() {
    final double safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final activeColor = const Color(0xFF1E7E6C); // Premium green/teal
    final inactiveColor = const Color(0xFF9CA3AF); // Slate/Grey

    return Container(
      width: double.infinity,
      height: _bottomNavBarHeight + safeAreaBottom,
      padding: EdgeInsets.only(bottom: safeAreaBottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(
            index: 0,
            label: 'Cameras',
            assetName: 'assets/cam.png',
            fallbackIcon: Icons.videocam_outlined,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
          _buildNavBarItem(
            index: 1,
            label: 'Categories',
            assetName: 'assets/categories.png',
            fallbackIcon: Icons.grid_view_rounded,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
          _buildNavBarItem(
            index: 2,
            label: 'Favorites',
            assetName: 'assets/heart.png',
            fallbackIcon: Icons.favorite_border_rounded,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
          _buildNavBarItem(
            index: 3,
            label: 'History',
            assetName: 'assets/clock.png',
            fallbackIcon: Icons.history_rounded,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavBarItem({
    required int index,
    required String label,
    required String assetName,
    required IconData fallbackIcon,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final bool isActive = _currentIndex == index;
    final color = isActive ? activeColor : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
            // Exit selection mode automatically when leaving history tab
            if (_currentIndex != 3) {
              _isSelectMode = false;
              _selectedHistoryIds.clear();
            }
            // Clear search query unless it's the Cameras view to let users view categories cleanly
            if (_currentIndex != 0) {
              _searchQuery = '';
              _searchController.clear();
            }
          });
        },
        splashColor: activeColor.withOpacity(0.05),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetName,
              width: 24,
              height: 24,
              color: color,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  fallbackIcon,
                  size: 24,
                  color: color,
                );
              },
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
