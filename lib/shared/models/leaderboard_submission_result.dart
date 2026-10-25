class LeaderboardSubmissionResult {
  final bool success;
  final String reason;
  final int? rank;
  final int? existingScore;

  const LeaderboardSubmissionResult({
    required this.success,
    required this.reason,
    this.rank,
    this.existingScore,
  });

  @override
  String toString() {
    return 'LeaderboardSubmissionResult(success: $success, reason: $reason, rank: $rank, existingScore: $existingScore)';
  }
}
