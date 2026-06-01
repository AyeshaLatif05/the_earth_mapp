import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// State provider managing the active tab index
// 0: Information, 1: Weather, 2: Location, 3: Travel
final activeTabProvider = StateProvider<int>((ref) => 3);

// State provider managing the active place index in the carousel
final activePlaceIndexProvider = StateProvider<int>((ref) => 0);

// State provider managing the active photo index in the Information tab swiper
final activeInfoImageIndexProvider = StateProvider<int>((ref) => 0);

// State provider managing the Google Map Type
final mapTypeProvider = StateProvider<MapType>((ref) => MapType.normal);

// State provider managing whether the map traffic layer is enabled
final trafficLayerProvider = StateProvider<bool>((ref) => false);

// State provider managing the saved home location name
final homeLocationProvider = StateProvider<String>((ref) => 'Add Home Location');
