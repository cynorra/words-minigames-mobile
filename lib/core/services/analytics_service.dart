import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._internal();
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logGameOpened({required String gameId, String? gameName}) async {
    try {
      await _analytics.logEvent(
        name: 'game_opened',
        parameters: <String, Object>{
          'game_id': gameId,
          if (gameName != null) 'game_name': gameName,
        },
      );
    } catch (_) {}
  }
}
