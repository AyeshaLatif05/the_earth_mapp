// lib/services/location_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  // Beşiktaş, Istanbul
  static const LatLng defaultLocation = LatLng(41.0438, 29.0067);

  /// Fetch the current location using Geolocator or IP-based geolocation fallback.
  static Future<LatLng> getCurrentLocation() async {
    try {
      // 1. Try to retrieve location via device GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 4),
          );
          return LatLng(position.latitude, position.longitude);
        }
      }
    } catch (e) {
      debugPrint('Geolocator failed, trying IP fallback: $e');
    }

    // 2. Fallback: Fetch location using IP geolocation (No permissions needed)
    try {
      final response = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final double? lat = (data['latitude'] as num?)?.toDouble();
        final double? lon = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lon != null) {
          debugPrint('Resolved location via ipapi.co: $lat, $lon');
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      debugPrint('ipapi.co lookup failed: $e');
    }

    try {
      final response = await http
          .get(Uri.parse('http://ip-api.com/json/'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final double? lat = (data['lat'] as num?)?.toDouble();
        final double? lon = (data['lon'] as num?)?.toDouble();
        if (lat != null && lon != null) {
          debugPrint('Resolved location via ip-api.com: $lat, $lon');
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      debugPrint('ip-api.com lookup failed: $e');
    }

    debugPrint('All geolocation attempts failed. Returning default location: $defaultLocation');
    return defaultLocation;
  }
}
