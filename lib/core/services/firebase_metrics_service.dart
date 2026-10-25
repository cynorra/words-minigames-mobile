import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMetricsService {
  FirebaseMetricsService._internal();
  static final FirebaseMetricsService _instance =
      FirebaseMetricsService._internal();
  factory FirebaseMetricsService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Increments only the 'openCount' of a game document in 'game_metrics/{gameId}'.
  /// Uses atomic increment and does not store any other fields.
  Future<void> incrementGameOpenCount(String gameId) async {
    try {
      final DocumentReference<Map<String, dynamic>> doc = _firestore
          .collection('game_metrics')
          .doc(gameId);

      await doc.set(<String, Object?>{
        'openCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (_) {
      // no-op; metrics failures shouldn't break UX
    }
  }
}
