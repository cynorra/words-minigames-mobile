class GlobalLeaderboardEntry {
  final String id;
  final String gameId;
  final String name;
  final String countryCode; // ISO alpha-2 (e.g., TR, US)
  final int score;

  const GlobalLeaderboardEntry({
    required this.id,
    required this.gameId,
    required this.name,
    required this.countryCode,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'name': name,
      'countryCode': countryCode,
      'score': score,
    };
  }

  factory GlobalLeaderboardEntry.fromMap(String id, Map<String, dynamic> data) {
    return GlobalLeaderboardEntry(
      id: id,
      gameId: (data['gameId'] ?? '') as String,
      name: (data['name'] ?? '') as String,
      countryCode: (data['countryCode'] ?? '') as String,
      score: (data['score'] ?? 0) as int,
    );
  }
}
