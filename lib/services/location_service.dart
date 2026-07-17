// lib/services/location_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  // Beşiktaş, Istanbul
  static const LatLng defaultLocation = LatLng(41.0438, 29.0067);
  static LatLng? _cachedLocation;

  /// Fetch the current location using Geolocator or IP-based geolocation fallback.
  static Future<LatLng> getCurrentLocation() async {
    // 0. Use cache if available
    if (_cachedLocation != null) {
      return _cachedLocation!;
    }

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
          // Check last known position first (instantly available)
          Position? lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) {
            _cachedLocation = LatLng(lastKnown.latitude, lastKnown.longitude);
            return _cachedLocation!;
          }

          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 3),
          );
          _cachedLocation = LatLng(position.latitude, position.longitude);
          return _cachedLocation!;
        }
      }
    } catch (e) {
      debugPrint('Geolocator failed, trying IP fallback: $e');
    }

    // 2. Fallback: Fetch location using IP geolocation (No permissions needed)
    try {
      final response = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final double? lat = (data['latitude'] as num?)?.toDouble();
        final double? lon = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lon != null) {
          debugPrint('Resolved location via ipapi.co: $lat, $lon');
          _cachedLocation = LatLng(lat, lon);
          return _cachedLocation!;
        }
      }
    } catch (e) {
      debugPrint('ipapi.co lookup failed: $e');
    }

    try {
      final response = await http
          .get(Uri.parse('http://ip-api.com/json/'))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final double? lat = (data['lat'] as num?)?.toDouble();
        final double? lon = (data['lon'] as num?)?.toDouble();
        if (lat != null && lon != null) {
          debugPrint('Resolved location via ip-api.com: $lat, $lon');
          _cachedLocation = LatLng(lat, lon);
          return _cachedLocation!;
        }
      }
    } catch (e) {
      debugPrint('ip-api.com lookup failed: $e');
    }

    debugPrint('All geolocation attempts failed. Returning default location: $defaultLocation');
    return defaultLocation;
  }
}
