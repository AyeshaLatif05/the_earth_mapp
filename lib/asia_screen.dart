import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'providers/travel_provider.dart';

class AsiaScreen extends ConsumerStatefulWidget {
  const AsiaScreen({super.key});

  @override
  ConsumerState<AsiaScreen> createState() => _AsiaScreenState();
}

class _AsiaScreenState extends ConsumerState<AsiaScreen> {
  // Page controllers for Travel tab and Info tab swiper
  late PageController _pageController;
  late PageController _infoImageController;

  // Local widget controllers are kept locally as they hold direct view handles
  GoogleMapController? _mapController;

  // The primary theme color of the app
  final Color _primaryColor = const Color(0xFF1E7E6C);

  // High quality list of destinations in Asia
  final List<Map<String, dynamic>> _destinations = [
    {
      'name': 'Passu Cones',
      'location': 'Hunza Valley, Pakistan',
      'displayLocation': 'Location here, Hunza Valley, Pakistan',
      'latitude': 36.4172,
      'longitude': 74.8892,
      'images': [
        'https://images.unsplash.com/photo-1627856013091-fed6e4e30025?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1606016159991-dfe4f974be5c?w=800&auto=format&fit=crop&q=80',
      ],
      'description': 'Passu Cones, also known as Passu Cathedral, are a collection of majestic, jagged peaks rising up to 6,106 meters in the Karakoram range. Located in the Hunza Valley of Pakistan, these striking rock needles are one of the most photographed natural landmarks along the Karakoram Highway.',
      'elevation': '6,106 m (20,033 ft)',
      'bestSeason': 'May to October',
      'funFact': 'The dramatic peaks resemble the spires of a Gothic cathedral, which is why explorers named them the "Cathedral Peaks".',
      'weather': {
        'temp': '16°',
        'condition': 'Breezy & Cool',
        'wind': '18 km/h',
        'humidity': '42%',
        'hourly': [
          {'temp': '14°C', 'time': '14:00', 'icon': Icons.wb_cloudy_rounded},
          {'temp': '15°C', 'time': '15:00', 'icon': Icons.wb_cloudy_rounded},
          {'temp': '16°C', 'time': '16:00', 'icon': Icons.cloud_queue_rounded, 'highlight': true},
          {'temp': '14°C', 'time': '17:00', 'icon': Icons.cloud_queue_rounded},
          {'temp': '12°C', 'time': '18:00', 'icon': Icons.cloud_queue_rounded},
        ],
        'forecast': [
          {'day': 'Sep, 13 MON', 'temp': '11°', 'icon': Icons.ac_unit_rounded},
          {'day': 'Sep, 14 TUE', 'temp': '12°', 'icon': Icons.cloud_queue_rounded},
          {'day': 'Sep, 15 WED', 'temp': '10°', 'icon': Icons.ac_unit_rounded},
          {'day': 'Sep, 16 THU', 'temp': '13°', 'icon': Icons.wb_sunny_rounded},
          {'day': 'Sep, 17 FRI', 'temp': '12°', 'icon': Icons.wb_sunny_rounded},
        ]
      }
    },
    {
      'name': 'Petra',
      'location': 'Maan Governorate, Jordan',
      'displayLocation': 'Location here, Rawalpindi, Pakistan', // Match exact screenshot string
      'latitude': 30.3285,
      'longitude': 35.4444,
      'images': [
        'https://images.unsplash.com/photo-1541432901042-2d8bd64b4a9b?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1501233360676-ef99f917c1d0?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1572435239385-d8ee066f3623?w=800&auto=format&fit=crop&q=80',
      ],
      'description': 'Petra is an ancient city carved into rose-red cliffs in southern Jordan. It was built by the Nabataean over 2,000 years ago as a major trading center. Petra is famous for its rock-cut architecture, especially the iconic Treasury. Today, it stands as one of the New Seven Wonders of the World.',
      'elevation': '810 m (2,657 ft)',
      'bestSeason': 'March to May',
      'funFact': 'Only about 15% of Petra has been explored by archaeologists; the remaining 85% is still untouched and underground.',
      'weather': {
        'temp': '34°',
        'condition': 'Sunny',
        'wind': '15 km/h',
        'humidity': '26 %',
        'hourly': [
          {'temp': '26°C', 'time': '16:00', 'icon': Icons.wb_cloudy_rounded},
          {'temp': '26°C', 'time': '17:00', 'icon': Icons.wb_cloudy_rounded, 'highlight': true},
          {'temp': '26°C', 'time': '16:00', 'icon': Icons.wb_cloudy_rounded},
          {'temp': '26°C', 'time': '16:00', 'icon': Icons.wb_cloudy_rounded},
          {'temp': '26°C', 'time': '16:00', 'icon': Icons.wb_cloudy_rounded},
        ],
        'forecast': [
          {'day': 'Sep, 13 MON', 'temp': '21°', 'icon': Icons.thunderstorm_rounded},
          {'day': 'Sep, 14 TUE', 'temp': '21°', 'icon': Icons.thunderstorm_rounded},
          {'day': 'Sep, 15 WED', 'temp': '21°', 'icon': Icons.thunderstorm_rounded},
          {'day': 'Sep, 16 THU', 'temp': '21°', 'icon': Icons.thunderstorm_rounded},
          {'day': 'Sep, 17 FRI', 'temp': '22°', 'icon': Icons.wb_sunny_rounded},
        ]
      }
    },
    {
      'name': 'Mount Fuji',
      'location': 'Honshu Island, Japan',
      'displayLocation': 'Location here, Honshu Island, Japan',
      'latitude': 35.3606,
      'longitude': 138.7274,
      'images': [
        'https://images.unsplash.com/photo-1490806843957-31f4c9a91c65?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1509023464722-18d996393ca8?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1578637387939-43c525550085?w=800&auto=format&fit=crop&q=80',
      ],
      'description': 'Mount Fuji is an active stratovolcano and Japan\'s tallest peak, rising majestically to 3,776 meters. Renowned for its exceptionally symmetrical cone, it is a sacred symbol of Japan, immortalized in countless works of art, and attracts thousands of hikers and climbers every year.',
      'elevation': '3,776 m (12,389 ft)',
      'bestSeason': 'July to September',
      'funFact': 'Mount Fuji is actually comprised of three separate volcanoes layered on top of each other: Komitake, Ko-Fuji, and Shin-Fuji.',
      'weather': {
        'temp': '8°',
        'condition': 'Clear & Crisp',
        'wind': '22 km/h',
        'humidity': '30%',
        'hourly': [
          {'temp': '6°C', 'time': '14:00', 'icon': Icons.ac_unit_rounded},
          {'temp': '7°C', 'time': '15:00', 'icon': Icons.ac_unit_rounded},
          {'temp': '8°C', 'time': '16:00', 'icon': Icons.ac_unit_rounded, 'highlight': true},
          {'temp': '7°C', 'time': '17:00', 'icon': Icons.wb_sunny_rounded},
          {'temp': '5°C', 'time': '18:00', 'icon': Icons.ac_unit_rounded},
        ],
        'forecast': [
          {'day': 'Sep, 13 MON', 'temp': '2°', 'icon': Icons.ac_unit_rounded},
          {'day': 'Sep, 14 TUE', 'temp': '3°', 'icon': Icons.ac_unit_rounded},
          {'day': 'Sep, 15 WED', 'temp': '1°', 'icon': Icons.ac_unit_rounded},
          {'day': 'Sep, 16 THU', 'temp': '4°', 'icon': Icons.wb_sunny_rounded},
          {'day': 'Sep, 17 FRI', 'temp': '3°', 'icon': Icons.wb_sunny_rounded},
        ]
      }
    },
    {
      'name': 'Taj Mahal',
      'location': 'Agra, India',
      'displayLocation': 'Location here, Agra, India',
      'latitude': 27.1751,
      'longitude': 78.0421,
      'images': [
        'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1585135497273-1a86b09fe70e?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1548013146-72479768bada?w=800&auto=format&fit=crop&q=80',
      ],
      'description': 'The Taj Mahal is an iconic white marble mausoleum built on the Yamuna River bank by Mughal Emperor Shah Jahan in memory of his beloved wife Mumtaz Mahal. A masterpiece of Mughal architecture, it is widely considered one of the New Seven Wonders of the World.',
      'elevation': 'Built 1643 AD',
      'bestSeason': 'October to March',
      'funFact': 'Depending on the time of the day and weather, the white marble Taj Mahal appears to change colors, glowing pink in the morning, golden in the evening, and milk-white under the moon.',
      'weather': {
        'temp': '32°',
        'condition': 'Sunny & Warm',
        'wind': '8 km/h',
        'humidity': '60%',
        'hourly': [
          {'temp': '30°C', 'time': '14:00', 'icon': Icons.wb_sunny_rounded},
          {'temp': '31°C', 'time': '15:00', 'icon': Icons.wb_sunny_rounded},
          {'temp': '32°C', 'time': '16:00', 'icon': Icons.wb_sunny_rounded, 'highlight': true},
          {'temp': '31°C', 'time': '17:00', 'icon': Icons.cloud_queue_rounded},
          {'temp': '29°C', 'time': '18:00', 'icon': Icons.wb_sunny_rounded},
        ],
        'forecast': [
          {'day': 'Sep, 13 MON', 'temp': '28°', 'icon': Icons.cloud_queue_rounded},
          {'day': 'Sep, 14 TUE', 'temp': '29°', 'icon': Icons.wb_sunny_rounded},
          {'day': 'Sep, 15 WED', 'temp': '30°', 'icon': Icons.wb_sunny_rounded},
          {'day': 'Sep, 16 THU', 'temp': '29°', 'icon': Icons.cloud_queue_rounded},
          {'day': 'Sep, 17 FRI', 'temp': '31°', 'icon': Icons.wb_sunny_rounded},
        ]
      }
    }
  ];

  @override
  void initState() {
    super.initState();
    // Initialize page controllers with default Riverpod values
    final activePlace = ref.read(activePlaceIndexProvider);
    final activeInfoImage = ref.read(activeInfoImageIndexProvider);
    _pageController = PageController(initialPage: activePlace);
    _infoImageController = PageController(initialPage: activeInfoImage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _infoImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers using Riverpod ref
    final activePlaceIndex = ref.watch(activePlaceIndexProvider);
    final activeTab = ref.watch(activeTabProvider);
    final activePlace = _destinations[activePlaceIndex];
    
    // Dynamic AppBar title based on the active tab!
    // Travel tab -> "Asia", other tabs -> active Destination name (e.g. "Petra", "Passu Cones")
    final String appBarTitle = activeTab == 3 ? 'Asia' : activePlace['name'];

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
        title: Text(
          appBarTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Dynamic Main Content Panel ──
            Expanded(
              child: _buildMainContent(activePlace, activeTab),
            ),

            // ── Bottom Navigation Tab Bar ──
            _buildBottomTabBar(activeTab),
          ],
        ),
      ),
    );
  }

  // ── Build Screen Content based on Current Selected Tab ──
  Widget _buildMainContent(Map<String, dynamic> place, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _buildInformationTab(place);
      case 1:
        return _buildWeatherTab(place);
      case 2:
        return _buildLocationTab(place);
      case 3:
      default:
        return _buildTravelTab(place);
    }
  }

  // ── TAB 0: INFORMATION VIEW (Fully Redesigned to Match Fourth Screenshot Specs) ──
  Widget _buildInformationTab(Map<String, dynamic> place) {
    final List<String> images = List<String>.from(place['images']);
    final activeInfoImageIndex = ref.watch(activeInfoImageIndexProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Large Place Image Swiper ──
          Container(
            height: 380,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _infoImageController,
                    onPageChanged: (idx) {
                      ref.read(activeInfoImageIndexProvider.notifier).state = idx;
                    },
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFFF3F4F6),
                            child: const Center(
                              child: CircularProgressIndicator(color: Color(0xFF1E7E6C)),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFE5E7EB),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Overlay indicators (green active dot, white inactive dots)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (index) {
                        final bool isActive = index == activeInfoImageIndex;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 10 : 8,
                          height: isActive ? 10 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? _primaryColor : Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Detailed Description ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              place['description'],
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F1F1F),
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Premium "Street View" Button ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                // Navigate seamlessly to the application's Street View route!
                Navigator.pushNamed(context, '/street_view');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
              ),
              child: const Text(
                'Street View',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16.5,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── TAB 1: WEATHER VIEW (Fully Redesigned to Match Third Screenshot Specs) ──
  Widget _buildWeatherTab(Map<String, dynamic> place) {
    final weather = place['weather'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main Header Row: 3D Icon on Left, Temp/Stats on Right ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Beautiful 3D smiling sun/cloud illustration stack
              Expanded(
                flex: 4,
                child: Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Sun back layer with glowing amber effects
                        Positioned(
                          top: 10,
                          left: 20,
                          child: Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [
                                  Color(0xFFFFD54F), // Bright soft yellow
                                  Color(0xFFFFB300), // Warm amber/orange
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFB300).withOpacity(0.35),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Tiny cute face eyes and smile matching screenshot icon
                                Positioned(
                                  top: 36,
                                  left: 26,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(color: Color(0xFF5D4037), shape: BoxShape.circle),
                                  ),
                                ),
                                Positioned(
                                  top: 36,
                                  right: 26,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(color: Color(0xFF5D4037), shape: BoxShape.circle),
                                  ),
                                ),
                                Positioned(
                                  top: 48,
                                  child: Container(
                                    width: 14,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF5D4037),
                                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(7)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Sun Rays (Visual lines/spokes)
                        Positioned(
                          top: 2,
                          left: 54,
                          child: _buildSunRay(14, 4, 0),
                        ),
                        Positioned(
                          top: 100,
                          left: 54,
                          child: _buildSunRay(14, 4, 0),
                        ),
                        Positioned(
                          top: 50,
                          left: 6,
                          child: _buildSunRay(4, 14, 0),
                        ),
                        Positioned(
                          top: 50,
                          left: 114,
                          child: _buildSunRay(4, 14, 0),
                        ),
                        
                        // Overlapping soft white 3D clouds
                        Positioned(
                          bottom: 12,
                          left: 36,
                          child: Container(
                            width: 106,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 8,
                          child: Container(
                            width: 76,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Temperature and Wind/Humidity Stats
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Temperature
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather['temp'],
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111111),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    
                    // Condition
                    Text(
                      weather['condition'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Wind Stat Row
                    Row(
                      children: [
                        const Icon(Icons.air_rounded, color: Color(0xFF1F1F1F), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Wind',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1F1F1F)),
                        ),
                        const Spacer(),
                        const Text(
                          '|',
                          style: TextStyle(fontSize: 15, color: Color(0xFFD1D5DB)),
                        ),
                        const Spacer(),
                        Text(
                          weather['wind'],
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Humidity Stat Row
                    Row(
                      children: [
                        const Icon(Icons.water_drop_outlined, color: Color(0xFF1F1F1F), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Hum',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1F1F1F)),
                        ),
                        const Spacer(),
                        const Text(
                          '|',
                          style: TextStyle(fontSize: 15, color: Color(0xFFD1D5DB)),
                        ),
                        const Spacer(),
                        Text(
                          weather['humidity'],
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Today Hourly Forecast Section ──
          const Text(
            'Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),

          // Horizontal row of hourly updates matching screen specs
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: (weather['hourly'] as List).length,
              itemBuilder: (context, idx) {
                final hr = weather['hourly'][idx];
                final bool isHighlight = hr['highlight'] == true;

                return Container(
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  width: 76,
                  decoration: BoxDecoration(
                    color: isHighlight ? const Color(0xFFF3F4F6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hr['temp'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                      Icon(
                        hr['icon'] as IconData,
                        color: Colors.amber[700],
                        size: 24,
                      ),
                      Text(
                        hr['time'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // ── Next 7 Days Section ──
          const Text(
            'Next 7 days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),

          // Vertical forecast rows matching screen specs
          Column(
            children: (weather['forecast'] as List).map<Widget>((fc) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        fc['day'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Icon(
                          fc['icon'] as IconData,
                          color: Colors.blueAccent,
                          size: 26,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          fc['temp'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Small helper to build sun rays
  Widget _buildSunRay(double w, double h, double r) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ── TAB 2: LOCATION VIEW (Upgraded High-Fidelity UI matching Screenshot) ──
  Widget _buildLocationTab(Map<String, dynamic> place) {
    final markerPosition = LatLng(place['latitude'] as double, place['longitude'] as double);
    final mapType = ref.watch(mapTypeProvider);
    final trafficEnabled = ref.watch(trafficLayerProvider);

    return Stack(
      children: [
        // ── Google Map Frame ──
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: markerPosition,
              zoom: 14.5,
            ),
            mapType: mapType,
            trafficEnabled: trafficEnabled,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            markers: {
              Marker(
                markerId: MarkerId(place['name']),
                position: markerPosition,
                infoWindow: InfoWindow(
                  title: place['name'],
                  snippet: place['location'],
                ),
              ),
            },
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
        ),

        // ── Left-Side Floating Control Buttons (3D, Globe, Traffic) ──
        Positioned(
          left: 16,
          top: 100,
          child: Column(
            children: [
              // 3D Button
              _buildFloatingControlBtn(
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF1F1F1F), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '3D',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ),
                onTap: () {
                  ref.read(mapTypeProvider.notifier).state =
                      mapType == MapType.normal ? MapType.satellite : MapType.normal;
                },
              ),
              const SizedBox(height: 12),

              // Globe Button
              _buildFloatingControlBtn(
                icon: Icons.public_rounded,
                onTap: () {
                  ref.read(mapTypeProvider.notifier).state =
                      mapType == MapType.hybrid ? MapType.normal : MapType.hybrid;
                },
              ),
              const SizedBox(height: 12),

              // Traffic Button
              _buildFloatingControlBtn(
                icon: Icons.traffic_rounded,
                iconColor: trafficEnabled ? Colors.green : const Color(0xFF1F1F1F),
                onTap: () {
                  ref.read(trafficLayerProvider.notifier).state = !trafficEnabled;
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(!trafficEnabled ? 'Traffic layer enabled' : 'Traffic layer disabled'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // ── Right-Side Floating Control Buttons (+ Zoom, - Zoom, Recenter) ──
        Positioned(
          right: 16,
          bottom: 180, // Elevated to sit nicely above bottom card
          child: Column(
            children: [
              // Zoom In (+)
              _buildFloatingControlBtn(
                icon: Icons.add,
                onTap: () {
                  _mapController?.animateCamera(CameraUpdate.zoomIn());
                },
              ),
              const SizedBox(height: 12),

              // Zoom Out (-)
              _buildFloatingControlBtn(
                icon: Icons.remove,
                onTap: () {
                  _mapController?.animateCamera(CameraUpdate.zoomOut());
                },
              ),
              const SizedBox(height: 12),

              // Target / Recenter GPS
              _buildFloatingControlBtn(
                icon: Icons.gps_fixed_rounded,
                onTap: () {
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: markerPosition, zoom: 15.0),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // ── Selected Location Card Frame at the bottom ──
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Selected Location" header
                const Text(
                  'Selected Location',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // Location Pin + Details Row
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFE53935),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        place['displayLocation'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Color(0xFF6B7280)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: place['displayLocation']));
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Location address copied to clipboard!'),
                            backgroundColor: _primaryColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      splashRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Premium Share Button
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sharing ${place['name']} location details...'),
                        backgroundColor: _primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Share',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Helper Floating Circular Control Button Widget ──
  Widget _buildFloatingControlBtn({
    IconData? icon,
    Color iconColor = const Color(0xFF1F1F1F),
    Widget? child,
    required VoidCallback onTap,
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child ?? Icon(icon, color: iconColor, size: 24),
      ),
    );
  }

  // ── TAB 3: TRAVEL VIEW (Default Carousel slider screen requested) ──
  Widget _buildTravelTab(Map<String, dynamic> place) {
    final activePlaceIndex = ref.watch(activePlaceIndexProvider);

    return Column(
      children: [
        const SizedBox(height: 12),

        // Carousel Container (Responsive size)
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) {
                      ref.read(activePlaceIndexProvider.notifier).state = idx;
                    },
                    itemCount: _destinations.length,
                    itemBuilder: (context, index) {
                      final item = _destinations[index];
                      return Image.network(
                        item['images'][0], // Use first premium image
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFFF3F4F6),
                            child: const Center(
                              child: CircularProgressIndicator(color: Color(0xFF1E7E6C)),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFE5E7EB),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Shadow gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black45,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Destination Name overlay (bottom-left)
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          place['location'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            shadows: const [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Dots Indicator peeking under the carousel
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_destinations.length, (index) {
            final isActive = index == activePlaceIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 12 : 8,
              height: isActive ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? _primaryColor : const Color(0xFFD1D5DB),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        // Giant Header matching exact placement of mockups
        Text(
          place['name'],
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111111),
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ── Premium Bottom Tab Bar precisely matching screenshot specs ──
  Widget _buildBottomTabBar(int activeTab) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(activeTab, 0, 'Information', Icons.info_outline_rounded),
          _buildTabItem(activeTab, 1, 'Weather', Icons.cloud_outlined),
          _buildTabItem(activeTab, 2, 'Location', Icons.location_on_outlined),
          _buildTabItem(activeTab, 3, 'Travel', Icons.airplanemode_active_outlined),
        ],
      ),
    );
  }

  Widget _buildTabItem(int activeTab, int index, String label, IconData icon) {
    final isActive = activeTab == index;
    final color = isActive ? _primaryColor : const Color(0xFF6B7280);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ref.read(activeTabProvider.notifier).state = index;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
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
