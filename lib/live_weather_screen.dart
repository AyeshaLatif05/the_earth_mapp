import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LiveWeatherScreen extends StatefulWidget {
  const LiveWeatherScreen({super.key});

  @override
  State<LiveWeatherScreen> createState() => _LiveWeatherScreenState();
}

class _LiveWeatherScreenState extends State<LiveWeatherScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = 'Rawalpindi';
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _liveWeatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData(_selectedCity);
  }

  // WMO codes mapping to conditions and icons
  Map<String, dynamic> _mapWmoCodeToCondition(int code) {
    switch (code) {
      case 0:
        return {'condition': 'Sunny Day', 'icon': Icons.wb_sunny_rounded};
      case 1:
      case 2:
      case 3:
        return {'condition': 'Partly Cloudy', 'icon': Icons.cloud_queue_rounded};
      case 45:
      case 48:
        return {'condition': 'Foggy', 'icon': Icons.blur_on_rounded};
      case 51:
      case 53:
      case 55:
        return {'condition': 'Drizzle', 'icon': Icons.grain_rounded};
      case 61:
      case 63:
      case 65:
        return {'condition': 'Rainy Day', 'icon': Icons.grain_rounded};
      case 71:
      case 73:
      case 75:
        return {'condition': 'Snowfall', 'icon': Icons.ac_unit_rounded};
      case 80:
      case 81:
      case 82:
        return {'condition': 'Rain Showers', 'icon': Icons.grain_rounded};
      case 95:
      case 96:
      case 99:
        return {'condition': 'Thunderstorm', 'icon': Icons.thunderstorm_rounded};
      default:
        return {'condition': 'Clear Sunny', 'icon': Icons.wb_sunny_rounded};
    }
  }

  Future<void> _fetchWeatherData(String cityName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Geocode City Name
      final String geocodeUrl =
          'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(cityName)}&count=1&language=en&format=json';
      final geocodeResponse = await http.get(Uri.parse(geocodeUrl));

      if (geocodeResponse.statusCode != 200) {
        throw Exception('Failed to connect to geocoding API');
      }

      final geocodeData = jsonDecode(geocodeResponse.body);
      if (geocodeData['results'] == null || (geocodeData['results'] as List).isEmpty) {
        throw Exception('City "$cityName" not found. Please try another.');
      }

      final result = geocodeData['results'][0];
      final double lat = result['latitude'];
      final double lon = result['longitude'];
      final String officialCityName = result['name'] ?? cityName;
      final String countryName = result['country'] ?? '';

      // 2. Fetch Forecast Details (current, hourly, daily)
      final String weatherUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,relative_humidity_2m,weathercode&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=auto';
      final weatherResponse = await http.get(Uri.parse(weatherUrl));

      if (weatherResponse.statusCode != 200) {
        throw Exception('Failed to fetch weather forecast data');
      }

      final weatherData = jsonDecode(weatherResponse.body);
      final current = weatherData['current_weather'];
      final currentCode = current['weathercode'] as int? ?? 0;
      final currentInfo = _mapWmoCodeToCondition(currentCode);

      // 3. Process Hourly Forecast (extract next 5 hours from current time index)
      final List hourlyTimes = weatherData['hourly']['time'] ?? [];
      final List hourlyTemps = weatherData['hourly']['temperature_2m'] ?? [];
      final List hourlyCodes = weatherData['hourly']['weathercode'] ?? [];
      final List hourlyHumidity = weatherData['hourly']['relative_humidity_2m'] ?? [];
      
      // Try to find the index corresponding to the current hour
      final int utcOffset = weatherData['utc_offset_seconds'] ?? 0;
      final DateTime nowLocal = DateTime.now().toUtc().add(Duration(seconds: utcOffset));
      int startIdx = 0;
      for (int i = 0; i < hourlyTimes.length; i++) {
        try {
          final DateTime t = DateTime.parse(hourlyTimes[i]);
          if (t.isAfter(nowLocal.subtract(const Duration(minutes: 30)))) {
            startIdx = i;
            break;
          }
        } catch (_) {}
      }

      final List<Map<String, dynamic>> processedHourly = [];
      for (int i = 0; i < 5; i++) {
        final int dataIdx = startIdx + i;
        if (dataIdx < hourlyTimes.length) {
          final double tempVal = (hourlyTemps[dataIdx] as num).toDouble();
          final int codeVal = hourlyCodes[dataIdx] as int? ?? 0;
          final mapped = _mapWmoCodeToCondition(codeVal);

          String timeLabel = '${dataIdx % 24}:00';
          try {
            final DateTime parsedTime = DateTime.parse(hourlyTimes[dataIdx]);
            final int hour = parsedTime.hour;
            if (hour == 0) {
              timeLabel = '12 AM';
            } else if (hour < 12) {
              timeLabel = '$hour AM';
            } else if (hour == 12) {
              timeLabel = '12 PM';
            } else {
              timeLabel = '${hour - 12} PM';
            }
          } catch (_) {}

          processedHourly.add({
            'time': i == 0 ? 'Now' : timeLabel,
            'temp': '${tempVal.round()}°',
            'icon': mapped['icon'],
            'highlight': i == 0,
          });
        }
      }

      // Get current humidity from hourly data
      String humidityString = '60%';
      if (startIdx < hourlyHumidity.length) {
        humidityString = '${hourlyHumidity[startIdx]}%';
      }

      // 4. Process 7-day Daily Forecast
      final List dailyTimes = weatherData['daily']['time'] ?? [];
      final List dailyMaxTemps = weatherData['daily']['temperature_2m_max'] ?? [];
      final List dailyCodes = weatherData['daily']['weathercode'] ?? [];

      final List<Map<String, dynamic>> processedForecast = [];
      final List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

      for (int i = 0; i < dailyTimes.length; i++) {
        if (i < dailyMaxTemps.length && i < dailyCodes.length) {
          final double maxTempVal = (dailyMaxTemps[i] as num).toDouble();
          final int codeVal = dailyCodes[i] as int? ?? 0;
          final mapped = _mapWmoCodeToCondition(codeVal);

          String dayLabel = 'Day ${i + 1}';
          try {
            final DateTime date = DateTime.parse(dailyTimes[i]);
            dayLabel = weekdays[date.weekday - 1];
          } catch (_) {}

          processedForecast.add({
            'day': dayLabel,
            'temp': '${maxTempVal.round()}°C',
            'icon': mapped['icon'],
          });
        }
      }

      setState(() {
        _selectedCity = officialCityName;
        _liveWeatherData = {
          'city': officialCityName,
          'country': countryName,
          'temp': '${(current['temperature'] as num).round()}°C',
          'condition': currentInfo['condition'],
          'wind': '${(current['windspeed'] as num).round()} km/h',
          'humidity': humidityString,
          'hourly': processedHourly,
          'forecast': processedForecast,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _searchCity() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _fetchWeatherData(query);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = _liveWeatherData;

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
                    final bool isSelected = _selectedCity.toLowerCase() == city.toLowerCase();
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCity = city;
                          _searchController.text = city;
                        });
                        _fetchWeatherData(city);
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

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: CircularProgressIndicator(
                      color: Color(0xFF1E7E6C),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (weather != null) ...[
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
            ],
          ),
        ),
      ),
    );
  }
}
