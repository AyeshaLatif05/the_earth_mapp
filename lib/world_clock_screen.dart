// lib/world_clock_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late Timer _timer;
  late DateTime _utcTime;

  // List of initial timezone zones with proper dynamic clock calculations
  final List<Map<String, dynamic>> _allTimezones = [
    {
      'city': 'Adelaide',
      'offsetLabel': '+9:30',
      'offsetDuration': const Duration(hours: 9, minutes: 30),
      'subtitle': 'Australian Standard Time',
      'flagEmoji': '🇦🇺',
    },
    {
      'city': 'Berlin',
      'offsetLabel': '+1:00',
      'offsetDuration': const Duration(hours: 1),
      'subtitle': 'Central European Time',
      'flagEmoji': '🇩🇪',
    },
    {
      'city': 'Tokyo',
      'offsetLabel': '+9:00',
      'offsetDuration': const Duration(hours: 9),
      'subtitle': 'Japan Standard Time',
      'flagEmoji': '🇯🇵',
    },
    {
      'city': 'New York',
      'offsetLabel': '-5:00',
      'offsetDuration': const Duration(hours: -5),
      'subtitle': 'Eastern Standard Time',
      'flagEmoji': '🇺🇸',
    },
    {
      'city': 'London',
      'offsetLabel': '+0:00',
      'offsetDuration': const Duration(hours: 0),
      'subtitle': 'Greenwich Mean Time',
      'flagEmoji': '🇬🇧',
    },
    {
      'city': 'Rawalpindi',
      'offsetLabel': '+5:00',
      'offsetDuration': const Duration(hours: 5),
      'subtitle': 'Pakistan Standard Time',
      'flagEmoji': '🇵🇰',
    },
  ];

  @override
  void initState() {
    super.initState();
    _utcTime = DateTime.now().toUtc();
    // Dynamic real-time ticking every second to WOW the user!
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _utcTime = DateTime.now().toUtc();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredZones() {
    if (_searchQuery.isEmpty) {
      return _allTimezones;
    }
    return _allTimezones
        .where((zone) =>
            zone['city'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            zone['subtitle'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Format time based on UTC offset
  String _formatLocalTime(Duration offset) {
    final localTime = _utcTime.add(offset);
    int hour = localTime.hour;
    final int minute = localTime.minute;
    final String period = hour >= 12 ? 'AM' : 'PM'; // Standard AM/PM formatting

    // Convert to 12-hour format
    hour = hour % 12;
    if (hour == 0) hour = 12;

    final String minuteStr = minute < 10 ? '0$minute' : '$minute';
    return '$hour:$minuteStr $period';
  }

  @override
  Widget build(BuildContext context) {
    final filteredZones = _getFilteredZones();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Minimalist Search Header Matching mockup exactly ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
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
                ],
              ),
            ),

            // ── Scrollable list of world times ──
            Expanded(
              child: filteredZones.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule_sharp, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No timezones match "$_searchQuery"',
                            style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredZones.length,
                      itemBuilder: (context, index) {
                        final zone = filteredZones[index];
                        final formattedTime = _formatLocalTime(zone['offsetDuration'] as Duration);

                        // Split local time for exact mockup dynamic styled text coloring
                        final timeParts = formattedTime.split(' ');
                        final timeDigits = timeParts[0];
                        final timePeriod = timeParts[1];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Circular Country Flag Badge
                              Container(
                                width: 36,
                                height: 36,
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
                                    zone['flagEmoji'],
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // City Offset Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${zone['city']} ${zone['offsetLabel']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      zone['subtitle'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Custom Teal Time Text
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    timeDigits,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E7E6C), // Bold custom mockup teal color
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    timePeriod,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
