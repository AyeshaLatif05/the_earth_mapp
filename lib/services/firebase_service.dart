import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton instance
  static final FirebaseService instance = FirebaseService._internal();
  FirebaseService._internal();

  // ────────── FEEDBACK ──────────

  /// Submit user feedback to Firestore
  Future<void> submitFeedback(String category, String content) async {
    await _db.collection('feedbacks').add({
      'category': category,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ────────── PARKING SPOTS ──────────

  /// Save a parked location to Firestore
  Future<void> saveParkingSpot({
    required String name,
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    await _db.collection('parkings').add({
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Retrieve a stream of all saved parking spots
  Stream<List<Map<String, dynamic>>> getParkingSpotStream() {
    return _db
        .collection('parkings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Parking Spot',
          'location': data['location'] ?? '',
          'latitude': (data['latitude'] as num?)?.toDouble() ?? 0.0,
          'longitude': (data['longitude'] as num?)?.toDouble() ?? 0.0,
        };
      }).toList();
    });
  }

  /// Delete a saved parking spot by ID
  Future<void> deleteParkingSpot(String id) async {
    await _db.collection('parkings').doc(id).delete();
  }

  // ────────── RATINGS ──────────

  /// Submit app rating
  Future<void> saveRating(int stars) async {
    await _db.collection('ratings').add({
      'stars': stars,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ────────── HOME LOCATION ──────────

  /// Save home location to a settings document
  Future<void> saveHomeLocation(String homeLoc) async {
    await _db.collection('settings').doc('home_location').set({
      'address': homeLoc,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch the saved home location from Firestore
  Future<String?> getHomeLocation() async {
    final doc = await _db.collection('settings').doc('home_location').get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!['address'] as String?;
    }
    return null;
  }
}
