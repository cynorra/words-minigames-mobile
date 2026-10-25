import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/global_leaderboard_entry.dart';
import '../../shared/models/user_ranking_info.dart';
import '../../shared/models/leaderboard_submission_result.dart';

class LeaderboardService {
  LeaderboardService._internal();
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;

  static const String _collection = 'leaderboards';
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns top N scores for a game, descending by score
  Future<List<GlobalLeaderboardEntry>> fetchTopEntries({
    required String gameId,
    int limit = 10,
  }) async {
    final snapshot =
        await _db
            .collection(_collection)
            .doc(gameId)
            .collection('entries')
            .orderBy('score', descending: true)
            .limit(limit)
            .get();

    return snapshot.docs
        .map((d) => GlobalLeaderboardEntry.fromMap(d.id, d.data()))
        .toList();
  }

  /// Check if user already has an entry in the leaderboard
  Future<GlobalLeaderboardEntry?> getUserExistingEntry({
    required String gameId,
    required String name,
    required String countryCode,
  }) async {
    final snapshot =
        await _db
            .collection(_collection)
            .doc(gameId)
            .collection('entries')
            .where('name', isEqualTo: name)
            .where('countryCode', isEqualTo: countryCode)
            .get();

    if (snapshot.docs.isEmpty) return null;

    // Return the highest score entry for this user
    final entries =
        snapshot.docs
            .map((d) => GlobalLeaderboardEntry.fromMap(d.id, d.data()))
            .toList();

    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries.first;
  }

  /// Check if user is currently in the top entries
  Future<bool> isUserInTopEntries({
    required String gameId,
    required String name,
    required String countryCode,
    int limit = 10,
  }) async {
    final topEntries = await fetchTopEntries(gameId: gameId, limit: limit);
    return topEntries.any(
      (entry) => entry.name == name && entry.countryCode == countryCode,
    );
  }

  /// Smart score submission that prevents duplicates and allows re-entry
  Future<LeaderboardSubmissionResult> submitScoreSmart({
    required String gameId,
    required String name,
    required String countryCode,
    required int score,
    int maxSize = 10,
  }) async {
    if (score <= 0) {
      return const LeaderboardSubmissionResult(
        success: false,
        reason: 'Score must be greater than 0',
        rank: null,
      );
    }

    final entriesRef = _db
        .collection(_collection)
        .doc(gameId)
        .collection('entries');

    // Check if user already has an entry
    final existingEntry = await getUserExistingEntry(
      gameId: gameId,
      name: name,
      countryCode: countryCode,
    );

    // Check if user is currently in top entries
    final isInTop = await isUserInTopEntries(
      gameId: gameId,
      name: name,
      countryCode: countryCode,
      limit: maxSize,
    );

    // Get current top entries to determine qualification
    final topEntries = await fetchTopEntries(gameId: gameId, limit: maxSize);

    // Determine if new score qualifies for top entries
    bool qualifiesForTop = false;
    if (topEntries.length < maxSize) {
      qualifiesForTop = true;
    } else if (topEntries.isNotEmpty && score > topEntries.last.score) {
      qualifiesForTop = true;
    }

    // Decision logic
    if (existingEntry != null) {
      // User has an existing entry
      if (isInTop) {
        // User is currently in top entries
        if (score <= existingEntry.score) {
          // New score is not better, don't allow duplicate
          return LeaderboardSubmissionResult(
            success: false,
            reason: 'You already have a better score in the leaderboard',
            rank: null,
            existingScore: existingEntry.score,
          );
        } else {
          // New score is better, delete old entry and add new one
          // First, delete all existing entries for this user
          final oldEntries =
              await _db
                  .collection(_collection)
                  .doc(gameId)
                  .collection('entries')
                  .where('name', isEqualTo: name)
                  .where('countryCode', isEqualTo: countryCode)
                  .get();

          final batch = _db.batch();
          for (final doc in oldEntries.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();

          // Add new entry with higher score
          await entriesRef.add({
            'gameId': gameId,
            'name': name,
            'countryCode': countryCode,
            'score': score,
          });

          // Trim if necessary to maintain maxSize
          await _trimLeaderboardEntries(gameId: gameId, maxSize: maxSize);

          // Get new rank
          final newRank = await getUserRank(gameId: gameId, score: score);
          return LeaderboardSubmissionResult(
            success: true,
            reason: 'Score updated successfully',
            rank: newRank,
            existingScore: existingEntry.score,
          );
        }
      } else {
        // User is not in top entries (fell out)
        if (qualifiesForTop) {
          // Score qualifies for top entries, allow re-entry
          await entriesRef.add({
            'gameId': gameId,
            'name': name,
            'countryCode': countryCode,
            'score': score,
          });

          // Clean up old entries for this user
          final oldEntries =
              await _db
                  .collection(_collection)
                  .doc(gameId)
                  .collection('entries')
                  .where('name', isEqualTo: name)
                  .where('countryCode', isEqualTo: countryCode)
                  .get();

          final batch = _db.batch();
          for (final doc in oldEntries.docs) {
            if (doc.id != existingEntry.id) {
              batch.delete(doc.reference);
            }
          }
          await batch.commit();

          // Trim if necessary to maintain maxSize
          await _trimLeaderboardEntries(gameId: gameId, maxSize: maxSize);

          // Get new rank
          final newRank = await getUserRank(gameId: gameId, score: score);
          return LeaderboardSubmissionResult(
            success: true,
            reason: 'Re-entered leaderboard successfully',
            rank: newRank,
            existingScore: existingEntry.score,
          );
        } else {
          // Score doesn't qualify for top entries
          return LeaderboardSubmissionResult(
            success: false,
            reason: 'Score does not qualify for top entries',
            rank: null,
            existingScore: existingEntry.score,
          );
        }
      }
    } else {
      // User has no existing entry
      if (qualifiesForTop) {
        // Score qualifies, add new entry
        await entriesRef.add({
          'gameId': gameId,
          'name': name,
          'countryCode': countryCode,
          'score': score,
        });

        // Trim if necessary to maintain maxSize
        await _trimLeaderboardEntries(gameId: gameId, maxSize: maxSize);

        // Get new rank
        final newRank = await getUserRank(gameId: gameId, score: score);
        return LeaderboardSubmissionResult(
          success: true,
          reason: 'Added to leaderboard successfully',
          rank: newRank,
          existingScore: null,
        );
      } else {
        // Score doesn't qualify
        return LeaderboardSubmissionResult(
          success: false,
          reason: 'Score does not qualify for top entries',
          rank: null,
          existingScore: null,
        );
      }
    }
  }

  /// Helper method to trim leaderboard entries to maintain maxSize
  Future<void> _trimLeaderboardEntries({
    required String gameId,
    required int maxSize,
  }) async {
    final entriesRef = _db
        .collection(_collection)
        .doc(gameId)
        .collection('entries');

    final updatedSnap =
        await entriesRef.orderBy('score', descending: true).get();
    if (updatedSnap.docs.length > maxSize) {
      final toDelete = updatedSnap.docs.skip(maxSize);
      final batch = _db.batch();
      for (final d in toDelete) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }

  /// Always saves the user's score and returns their rank
  Future<int> saveUserScore({
    required String gameId,
    required String name,
    required String countryCode,
    required int score,
  }) async {
    if (score <= 0) return 0;

    final entriesRef = _db
        .collection(_collection)
        .doc(gameId)
        .collection('entries');

    // Add new entry
    await entriesRef.add({
      'gameId': gameId,
      'name': name,
      'countryCode': countryCode,
      'score': score,
    });

    // Get user's rank
    return await getUserRank(gameId: gameId, score: score);
  }

  /// Get user's rank for a specific score
  Future<int> getUserRank({required String gameId, required int score}) async {
    if (score <= 0) return 0;

    final snapshot =
        await _db
            .collection(_collection)
            .doc(gameId)
            .collection('entries')
            .orderBy('score', descending: true)
            .get();

    final entries =
        snapshot.docs
            .map((d) => GlobalLeaderboardEntry.fromMap(d.id, d.data()))
            .toList();

    int rank = 1;
    for (final entry in entries) {
      if (score >= entry.score) break;
      rank++;
    }

    return rank;
  }

  /// Get user's actual leaderboard score
  Future<int> getUserLeaderboardScore({
    required String gameId,
    required int userScore,
  }) async {
    if (userScore <= 0) return 0;

    final snapshot =
        await _db
            .collection(_collection)
            .doc(gameId)
            .collection('entries')
            .orderBy('score', descending: true)
            .get();

    final entries =
        snapshot.docs
            .map((d) => GlobalLeaderboardEntry.fromMap(d.id, d.data()))
            .toList();

    // Find the user's entry in the leaderboard
    for (final entry in entries) {
      if (entry.score == userScore) {
        return entry.score;
      }
    }

    // If not found, return the user's score (it might not be in leaderboard yet)
    return userScore;
  }

  /// Get ranking range for a user (e.g., "11-50", "51-99", "100-199")
  String getRankingRange(int rank) {
    if (rank <= 10) return rank.toString();

    if (rank <= 50) return '11-50';
    if (rank <= 99) return '51-99';
    if (rank <= 199) return '100-199';
    if (rank <= 299) return '200-299';
    if (rank <= 399) return '300-399';
    if (rank <= 499) return '400-499';
    if (rank <= 999) return '500-999';

    return '1000+';
  }

  /// Get comprehensive user ranking information
  Future<UserRankingInfo> getUserRankingInfo({
    required String gameId,
    required int userScore,
  }) async {
    if (userScore <= 0) {
      return const UserRankingInfo(
        rank: 0,
        rankingRange: 'N/A',
        totalEntries: 0,
        userScore: 0,
        leaderboardScore: 0,
      );
    }

    final rank = await getUserRank(gameId: gameId, score: userScore);
    final totalEntries = await getTotalEntries(gameId);
    final rankingRange = getRankingRange(rank);

    // Get the user's actual leaderboard score
    final leaderboardScore = await getUserLeaderboardScore(
      gameId: gameId,
      userScore: userScore,
    );

    return UserRankingInfo(
      rank: rank,
      rankingRange: rankingRange,
      totalEntries: totalEntries,
      userScore: userScore,
      leaderboardScore: leaderboardScore,
    );
  }

  /// Get total number of entries for a game
  Future<int> getTotalEntries(String gameId) async {
    final snapshot =
        await _db
            .collection(_collection)
            .doc(gameId)
            .collection('entries')
            .count()
            .get();

    return snapshot.count ?? 0;
  }

  /// Returns the rank if this score were inserted now. If rank <= 10, it qualifies.
  /// Rank is 1-based.
  Future<int?> getProvisionalRank({
    required String gameId,
    required int score,
    int maxSize = 10,
  }) async {
    if (score <= 0) return null;
    final top = await fetchTopEntries(gameId: gameId, limit: maxSize);
    // If less than maxSize entries, always qualifies and rank is len+1 position by score
    if (top.isEmpty) return 1;

    int rank = 1;
    for (final e in top) {
      if (score > e.score) break;
      rank++;
    }

    if (top.length < maxSize && rank > top.length) {
      // fits at the end
      return top.length + 1;
    }

    if (rank <= maxSize) {
      return rank;
    }
    return null;
  }

  /// Inserts the score if it qualifies. Keeps only top N entries.
  Future<void> upsertQualifiedEntry({
    required String gameId,
    required String name,
    required String countryCode,
    required int score,
    int maxSize = 10,
  }) async {
    final entriesRef = _db
        .collection(_collection)
        .doc(gameId)
        .collection('entries');

    // Read top to decide qualification
    final topSnap =
        await entriesRef
            .orderBy('score', descending: true)
            .limit(maxSize)
            .get();

    final top =
        topSnap.docs
            .map((d) => GlobalLeaderboardEntry.fromMap(d.id, d.data()))
            .toList();

    bool qualifies = false;
    if (top.length < maxSize) {
      qualifies = true;
    } else if (top.isNotEmpty && score > top.last.score) {
      qualifies = true;
    }

    if (!qualifies) return;

    // Add new entry
    await entriesRef.add({
      'gameId': gameId,
      'name': name,
      'countryCode': countryCode,
      'score': score,
    });

    // Trim if necessary
    final updatedSnap =
        await entriesRef.orderBy('score', descending: true).get();
    if (updatedSnap.docs.length > maxSize) {
      final toDelete = updatedSnap.docs.skip(maxSize);
      final batch = _db.batch();
      for (final d in toDelete) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }
}
