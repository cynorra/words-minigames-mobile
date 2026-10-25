class UserRankingInfo {
  final int rank;
  final String rankingRange;
  final int totalEntries;
  final int userScore;
  final int leaderboardScore;

  const UserRankingInfo({
    required this.rank,
    required this.rankingRange,
    required this.totalEntries,
    required this.userScore,
    required this.leaderboardScore,
  });

  /// Check if user is in top 10
  bool get isInTopTen => rank <= 10;

  /// Check if user is in top 50
  bool get isInTopFifty => rank <= 50;

  /// Check if user is in top 100
  bool get isInTopHundred => rank <= 100;

  /// Get percentage position (lower is better)
  double get percentagePosition {
    if (totalEntries == 0) return 0.0;
    return (rank / totalEntries) * 100;
  }

  /// Get formatted rank display
  String get rankDisplay {
    if (isInTopTen) {
      return rank.toString();
    }
    return rankingRange;
  }

  /// Get rank description
  String get rankDescription {
    if (rank == 1) return '1st';
    if (rank == 2) return '2nd';
    if (rank == 3) return '3rd';
    if (rank <= 10) return '${rank}th';

    return rankingRange;
  }
}
