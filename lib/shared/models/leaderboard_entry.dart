class LeaderboardEntry {
  final String gameId;
  final int highScore;
  final DateTime? lastPlayed;

  const LeaderboardEntry({
    required this.gameId,
    required this.highScore,
    this.lastPlayed,
  });

  LeaderboardEntry copyWith({
    String? gameId,
    int? highScore,
    DateTime? lastPlayed,
  }) {
    return LeaderboardEntry(
      gameId: gameId ?? this.gameId,
      highScore: highScore ?? this.highScore,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'highScore': highScore,
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      gameId: json['gameId'] as String,
      highScore: json['highScore'] as int,
      lastPlayed:
          json['lastPlayed'] != null
              ? DateTime.parse(json['lastPlayed'] as String)
              : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardEntry &&
        other.gameId == gameId &&
        other.highScore == highScore &&
        other.lastPlayed == lastPlayed;
  }

  @override
  int get hashCode {
    return Object.hash(gameId, highScore, lastPlayed);
  }

  @override
  String toString() {
    return 'LeaderboardEntry(gameId: $gameId, highScore: $highScore, lastPlayed: $lastPlayed)';
  }
}
