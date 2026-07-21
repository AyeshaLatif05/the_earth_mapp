import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LiveStreamPlayerScreen extends StatefulWidget {
  const LiveStreamPlayerScreen({super.key});

  @override
  State<LiveStreamPlayerScreen> createState() => _LiveStreamPlayerScreenState();
}

class _LiveStreamPlayerScreenState extends State<LiveStreamPlayerScreen> {
  bool _isPlaying = true;
  bool _isLiked = false;
  int _likesCount = 1299;
  int _viewsCount = 12345;

  late Map<String, dynamic> _activeCamera;
  bool _isInitialized = false;

  VideoPlayerController? _videoController;
  bool _isVideoLoading = true;
  bool _isMuted = false;

  // Standard mock list of all camera options (shared with cameras_screen.dart)
  final List<Map<String, dynamic>> _recommendedCameras = [
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        _activeCamera = args;
      } else {
        // Fallback to default
        _activeCamera = _recommendedCameras[0];
      }
      _isLiked = _activeCamera['isFavorite'] ?? false;
      _isInitialized = true;
      _initVideoPlayer();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initVideoPlayer() async {
    setState(() {
      _isVideoLoading = true;
    });

    await _videoController?.dispose();
    _videoController = null;

    final String? rawUrl = _activeCamera['videoUrl'];
    final bool isLocal = _activeCamera['isLocalFile'] == true;

    try {
      if (isLocal && rawUrl != null && rawUrl.isNotEmpty) {
        _videoController = VideoPlayerController.file(File(rawUrl));
      } else {
        final String streamUrl = (rawUrl != null && rawUrl.isNotEmpty)
            ? rawUrl
            : 'https://assets.mixkit.co/videos/preview/mixkit-earth-rotating-in-space-42683-large.mp4';
        _videoController = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
      }

      await _videoController!.initialize();
      _videoController!.setLooping(true);
      if (_isPlaying) {
        await _videoController!.play();
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    }
  }

  void _selectCamera(Map<String, dynamic> camera) {
    setState(() {
      _activeCamera = camera;
      _isLiked = camera['isFavorite'] ?? false;
      _isPlaying = true;
      // Scramble views & likes slightly to simulate a real dynamic platform!
      _viewsCount = 10000 + (camera['id'].hashCode % 15000);
      _likesCount = 500 + (camera['id'].hashCode % 1000);
    });
    _initVideoPlayer();
  }

  void _togglePlay() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      if (_isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleMute() {
    if (_videoController != null) {
      _videoController!.setVolume(_isMuted ? 1.0 : 0.0);
      setState(() {
        _isMuted = !_isMuted;
      });
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likesCount++;
      } else {
        _likesCount--;
      }
    });
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF1E8278)),
            const SizedBox(width: 10),
            Text(
              _activeCamera['countryName'] ?? 'Location Info',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'This live stream is broadcasting from ${_activeCamera['countryName']} (${_activeCamera['flagEmoji']}). Category: ${_activeCamera['category']}.',
          style: const TextStyle(fontSize: 15, height: 1.4, color: Color(0xFF4B5563)),
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
    // Exclude the active camera from recommended cameras list
    final recommendations = _recommendedCameras
        .where((cam) => cam['id'] != _activeCamera['id'])
        .toList();

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
        title: const Text(
          'Live Camera',
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top Video Player Preview ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: Stack(
                      children: [
                        // Video Stream Player or Fallback Image
                        Positioned.fill(
                          child: _videoController != null && _videoController!.value.isInitialized
                              ? SizedBox.expand(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    clipBehavior: Clip.hardEdge,
                                    child: SizedBox(
                                      width: _videoController!.value.size.width > 0
                                          ? _videoController!.value.size.width
                                          : 16,
                                      height: _videoController!.value.size.height > 0
                                          ? _videoController!.value.size.height
                                          : 9,
                                      child: VideoPlayer(_videoController!),
                                    ),
                                  ),
                                )
                              : _isVideoLoading
                                  ? Container(
                                      color: const Color(0xFF111111),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF1E7E6C),
                                        ),
                                      ),
                                    )
                                  : Image.network(
                                      _activeCamera['imageUrl'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: const Color(0xFF111111),
                                          child: const Center(
                                            child: Icon(
                                              Icons.error_outline_rounded,
                                              color: Colors.white54,
                                              size: 32,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                        ),

                        // Play/Pause circular toggle overlay
                        Center(
                          child: GestureDetector(
                            onTap: _togglePlay,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white30, width: 1.5),
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ),

                        // Bottom progress/buffer indicators
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                // Red flashing live badge
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _toggleMute,
                                  child: Icon(
                                    _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.hd_rounded, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── 2. Stream Details Tag & Views Counter ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Text(
                  _activeCamera['name'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_viewsCount',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── 3. Actions Button Row ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Likes Button
                    Expanded(
                      child: GestureDetector(
                        onTap: _toggleLike,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: _isLiked ? Colors.red : const Color(0xFF4B5563),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '$_likesCount Likes',
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Location Button
                    Expanded(
                      child: GestureDetector(
                        onTap: _showLocationDialog,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E8278), // Teal color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── 4. Recommended Streams Grid ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recommended For You',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111111),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.82,
                ),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final camera = recommendations[index];
                  return _buildRecommendationCard(camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> camera) {
    final bool isFav = camera['isFavorite'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Image with play overlay
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      camera['imageUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Circular Play button overlay matching mockup precisely
                  Center(
                    child: GestureDetector(
                      onTap: () => _selectCamera(camera),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Footer Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Circular Country Flag Emoji
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          camera['flagEmoji'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),

                      // Heart Fav trigger
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            camera['isFavorite'] = !isFav;
                          });
                        },
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? Colors.red : const Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Camera Name label
                  Text(
                    camera['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
