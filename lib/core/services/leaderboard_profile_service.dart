import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardProfileService {
  LeaderboardProfileService._internal();
  static final LeaderboardProfileService _instance =
      LeaderboardProfileService._internal();
  factory LeaderboardProfileService() => _instance;

  static const String _keyName = 'leaderboard_profile_name';
  static const String _keyCountryCode = 'leaderboard_profile_country_code';

  Future<void> saveProfile({
    required String name,
    required String countryCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyCountryCode, countryCode);
  }

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  Future<String?> getCountryCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCountryCode);
  }

  Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyName) && prefs.containsKey(_keyCountryCode);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyCountryCode);
  }
}
