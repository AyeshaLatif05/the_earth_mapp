import 'package:flutter/material.dart';

class LiveWeatherScreen extends StatefulWidget {
  const LiveWeatherScreen({super.key});

  @override
  State<LiveWeatherScreen> createState() => _LiveWeatherScreenState();
}

class _LiveWeatherScreenState extends State<LiveWeatherScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = 'Rawalpindi';

  // Complete mock weather database with detailed info
  final Map<String, Map<String, dynamic>> _weatherDatabase = {
    'rawalpindi': {
      'city': 'Rawalpindi',
      'country': 'Pakistan',
      'temp': '32°C',
      'condition': 'Sunny Day',
      'wind': '12 km/h',
      'humidity': '45%',
      'hourly': [
        {'time': 'Now', 'temp': '32°', 'icon': Icons.wb_sunny_rounded, 'highlight': true},
        {'time': '12 PM', 'temp': '34°', 'icon': Icons.wb_sunny_rounded},
        {'time': '2 PM', 'temp': '35°', 'icon': Icons.wb_sunny_rounded},
        {'time': '4 PM', 'temp': '33°', 'icon': Icons.wb_sunny_rounded},
        {'time': '6 PM', 'temp': '30°', 'icon': Icons.wb_sunny_outlined},
      ],
      'forecast': [
        {'day': 'Monday', 'temp': '33°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Tuesday', 'temp': '35°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Wednesday', 'temp': '34°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Thursday', 'temp': '31°C', 'icon': Icons.cloud_queue_rounded},
        {'day': 'Friday', 'temp': '30°C', 'icon': Icons.ac_unit_rounded},
        {'day': 'Saturday', 'temp': '32°C', 'icon': Icons.cloud_queue_rounded},
        {'day': 'Sunday', 'temp': '34°C', 'icon': Icons.wb_sunny_rounded},
      ],
    },
    'new york': {
      'city': 'New York',
      'country': 'United States',
      'temp': '22°C',
      'condition': 'Partly Cloudy',
      'wind': '18 km/h',
      'humidity': '60%',
      'hourly': [
        {'time': 'Now', 'temp': '22°', 'icon': Icons.cloud_queue_rounded, 'highlight': true},
        {'time': '12 PM', 'temp': '23°', 'icon': Icons.cloud_queue_rounded},
        {'time': '2 PM', 'temp': '24°', 'icon': Icons.wb_cloudy_rounded},
        {'time': '4 PM', 'temp': '22°', 'icon': Icons.wb_cloudy_rounded},
        {'time': '6 PM', 'temp': '20°', 'icon': Icons.cloud_queue_rounded},
      ],
      'forecast': [
        {'day': 'Monday', 'temp': '23°C', 'icon': Icons.cloud_queue_rounded},
        {'day': 'Tuesday', 'temp': '24°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Wednesday', 'temp': '22°C', 'icon': Icons.wb_cloudy_rounded},
        {'day': 'Thursday', 'temp': '19°C', 'icon': Icons.grain_rounded},
        {'day': 'Friday', 'temp': '20°C', 'icon': Icons.cloud_queue_rounded},
        {'day': 'Saturday', 'temp': '21°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Sunday', 'temp': '23°C', 'icon': Icons.wb_sunny_rounded},
      ],
    },
    'london': {
      'city': 'London',
      'country': 'United Kingdom',
      'temp': '16°C',
      'condition': 'Showers / Rain',
      'wind': '22 km/h',
      'humidity': '82%',
      'hourly': [
        {'time': 'Now', 'temp': '16°', 'icon': Icons.grain_rounded, 'highlight': true},
        {'time': '12 PM', 'temp': '17°', 'icon': Icons.grain_rounded},
        {'time': '2 PM', 'temp': '18°', 'icon': Icons.cloud_queue_rounded},
        {'time': '4 PM', 'temp': '16°', 'icon': Icons.grain_rounded},
        {'time': '6 PM', 'temp': '15°', 'icon': Icons.wb_cloudy_rounded},
      ],
      'forecast': [
        {'day': 'Monday', 'temp': '17°C', 'icon': Icons.grain_rounded},
        {'day': 'Tuesday', 'temp': '18°C', 'icon': Icons.cloud_queue_rounded},
        {'day': 'Wednesday', 'temp': '16°C', 'icon': Icons.grain_rounded},
        {'day': 'Thursday', 'temp': '15°C', 'icon': Icons.wb_cloudy_rounded},
        {'day': 'Friday', 'temp': '14°C', 'icon': Icons.grain_rounded},
        {'day': 'Saturday', 'temp': '16°C', 'icon': Icons.cloud_queue_rounded},
        {'day': 'Sunday', 'temp': '18°C', 'icon': Icons.wb_sunny_rounded},
      ],
    },
    'paris': {
      'city': 'Paris',
      'country': 'France',
      'temp': '19°C',
      'condition': 'Cloudy Sky',
      'wind': '15 km/h',
      'humidity': '68%',
      'hourly': [
        {'time': 'Now', 'temp': '19°', 'icon': Icons.wb_cloudy_rounded, 'highlight': true},
        {'time': '12 PM', 'temp': '20°', 'icon': Icons.wb_cloudy_rounded},
        {'time': '2 PM', 'temp': '21°', 'icon': Icons.cloud_queue_rounded},
        {'time': '4 PM', 'temp': '19°', 'icon': Icons.wb_cloudy_rounded},
        {'time': '6 PM', 'temp': '18°', 'icon': Icons.cloud_queue_rounded},
      ],
      'forecast': [
        {'day': 'Monday', 'temp': '20°C', 'icon': Icons.wb_cloudy_rounded},
        {'day': 'Tuesday', 'temp': '21°C', 'icon': Icons.cloud_queue_rounded},
        {'day': 'Wednesday', 'temp': '19°C', 'icon': Icons.wb_cloudy_rounded},
        {'day': 'Thursday', 'temp': '18°C', 'icon': Icons.grain_rounded},
        {'day': 'Friday', 'temp': '17°C', 'icon': Icons.cloud_queue_rounded},
        {'day': 'Saturday', 'temp': '19°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Sunday', 'temp': '21°C', 'icon': Icons.wb_sunny_rounded},
      ],
    },
    'tokyo': {
      'city': 'Tokyo',
      'country': 'Japan',
      'temp': '25°C',
      'condition': 'Pleasant',
      'wind': '10 km/h',
      'humidity': '50%',
      'hourly': [
        {'time': 'Now', 'temp': '25°', 'icon': Icons.wb_sunny_rounded, 'highlight': true},
        {'time': '12 PM', 'temp': '26°', 'icon': Icons.wb_sunny_rounded},
        {'time': '2 PM', 'temp': '27°', 'icon': Icons.wb_sunny_rounded},
        {'time': '4 PM', 'temp': '24°', 'icon': Icons.cloud_queue_rounded},
        {'time': '6 PM', 'temp': '22°', 'icon': Icons.cloud_queue_rounded},
      ],
      'forecast': [
        {'day': 'Monday', 'temp': '26°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Tuesday', 'temp': '27°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Wednesday', 'temp': '25°C', 'icon': Icons.cloud_queue_rounded},
        {'day': 'Thursday', 'temp': '23°C', 'icon': Icons.cloud_queue_rounded},
        {'day': 'Friday', 'temp': '24°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Saturday', 'temp': '25°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Sunday', 'temp': '26°C', 'icon': Icons.wb_sunny_rounded},
      ],
    },
    'istanbul': {
      'city': 'Istanbul',
      'country': 'Turkey',
      'temp': '26°C',
      'condition': 'Clear Sunny',
      'wind': '14 km/h',
      'humidity': '55%',
      'hourly': [
        {'time': 'Now', 'temp': '26°', 'icon': Icons.wb_sunny_rounded, 'highlight': true},
        {'time': '12 PM', 'temp': '28°', 'icon': Icons.wb_sunny_rounded},
        {'time': '2 PM', 'temp': '29°', 'icon': Icons.wb_sunny_rounded},
        {'time': '4 PM', 'temp': '27°', 'icon': Icons.wb_sunny_rounded},
        {'time': '6 PM', 'temp': '24°', 'icon': Icons.wb_sunny_outlined},
      ],
      'forecast': [
        {'day': 'Monday', 'temp': '28°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Tuesday', 'temp': '29°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Wednesday', 'temp': '27°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Thursday', 'temp': '25°C', 'icon': Icons.cloud_queue_rounded},
        {'day': 'Friday', 'temp': '24°C', 'icon': Icons.cloud_queue_rounded},
        {'day': 'Saturday', 'temp': '26°C', 'icon': Icons.wb_sunny_rounded},
        {'day': 'Sunday', 'temp': '28°C', 'icon': Icons.wb_sunny_rounded},
      ],
    },
  };

  Map<String, dynamic> get _currentWeather {
    final String key = _selectedCity.trim().toLowerCase();
    return _weatherDatabase[key] ?? _weatherDatabase['rawalpindi']!;
  }

  void _searchCity() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      final key = query.toLowerCase();
      if (_weatherDatabase.containsKey(key)) {
        setState(() {
          _selectedCity = _weatherDatabase[key]!['city'];
        });
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Weather data for "$query" not found. Showing default.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        setState(() {
          _selectedCity = 'Rawalpindi';
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = _currentWeather;

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
          'Live Weather',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Search field ──
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _searchCity(),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFF1E7E6C)),
                      onPressed: _searchCity,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Popular Cities Quick bar ──
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    'Rawalpindi',
                    'New York',
                    'London',
                    'Paris',
                    'Tokyo',
                    'Istanbul',
                  ].map((city) {
                    final bool isSelected = _selectedCity == city;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCity = city;
                          _searchController.text = city;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E7E6C) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          city,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // ── Weather Card precisely matching aesthetic specs ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Row(
                  children: [
                    // Cute Smiling Sun/Cloud Face Stack
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: 5,
                                left: 15,
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        top: 30,
                                        left: 22,
                                        child: Container(
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(color: Color(0xFF5D4037), shape: BoxShape.circle),
                                        ),
                                      ),
                                      Positioned(
                                        top: 30,
                                        right: 22,
                                        child: Container(
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(color: Color(0xFF5D4037), shape: BoxShape.circle),
                                        ),
                                      ),
                                      Positioned(
                                        top: 40,
                                        child: Container(
                                          width: 10,
                                          height: 5,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF5D4037),
                                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 25,
                                child: Container(
                                  width: 80,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Temperature and metrics column
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather['city'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111111),
                            ),
                          ),
                          Text(
                            weather['country'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weather['temp'],
                            style: const TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111111),
                              height: 1.1,
                            ),
                          ),
                          Text(
                            weather['condition'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E7E6C),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.air_rounded, color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Text(weather['wind'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              const Icon(Icons.water_drop_outlined, color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Text(weather['humidity'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Today Hourly Forecast ──
              const Text(
                'Hourly Forecast',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: (weather['hourly'] as List).length,
                  itemBuilder: (context, idx) {
                    final hr = weather['hourly'][idx];
                    final bool isHighlight = hr['highlight'] == true;

                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      width: 72,
                      decoration: BoxDecoration(
                        color: isHighlight ? const Color(0xFFF3F4F6) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isHighlight ? Colors.transparent : const Color(0xFFF3F4F6),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hr['temp'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111111),
                            ),
                          ),
                          Icon(
                            hr['icon'] as IconData,
                            color: Colors.amber[700],
                            size: 20,
                          ),
                          Text(
                            hr['time'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Next 7 Days ──
              const Text(
                'Next 7 days',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              Column(
                children: (weather['forecast'] as List).map<Widget>((fc) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            fc['day'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Icon(
                              fc['icon'] as IconData,
                              color: Colors.blueAccent,
                              size: 22,
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
                                fontSize: 14,
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
