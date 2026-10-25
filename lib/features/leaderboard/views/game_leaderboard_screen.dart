import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:quicko_app/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../core/services/leaderboard_service.dart';
import '../../../shared/models/global_leaderboard_entry.dart';
import '../../../shared/models/user_ranking_info.dart';
import '../../../core/utils/leaderboard_utils.dart';
import '../../../core/services/leaderboard_profile_service.dart';
import '../../../shared/widgets/app_bars.dart';

class GameLeaderboardScreen extends StatefulWidget {
  final String gameId;
  final String title;

  const GameLeaderboardScreen({
    super.key,
    required this.gameId,
    required this.title,
  });

  @override
  State<GameLeaderboardScreen> createState() => _GameLeaderboardScreenState();
}

class _GameLeaderboardScreenState extends State<GameLeaderboardScreen>
    with TickerProviderStateMixin {
  late Future<Map<String, dynamic>> _allDataFuture;
  UserRankingInfo? _userRanking;
  String? _userName;
  String? _userCountryCode;
  late AnimationController _shimmerController;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _starController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _loadAllData();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _starController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    _allDataFuture = _loadAllDataAsync();
  }

  Future<Map<String, dynamic>> _loadAllDataAsync() async {
    try {
      // Load leaderboard data
      final leaderboardFuture = LeaderboardService().fetchTopEntries(
        gameId: widget.gameId,
      );

      // Load user profile info
      final profileService = LeaderboardProfileService();
      final userName = await profileService.getName();
      final userCountryCode = await profileService.getCountryCode();

      final userScore = await LeaderboardUtils.getHighScore(widget.gameId);
      UserRankingInfo? userRanking;

      if (userScore > 0) {
        userRanking = await LeaderboardService().getUserRankingInfo(
          gameId: widget.gameId,
          userScore: userScore,
        );
      }

      // Wait for leaderboard data
      final leaderboardData = await leaderboardFuture;

      // Update state
      if (mounted) {
        setState(() {
          _userName = userName;
          _userCountryCode = userCountryCode;
          _userRanking = userRanking;
        });
      }

      return {'leaderboard': leaderboardData, 'userRanking': userRanking};
    } catch (e) {
      // Return empty data on error
      return {'leaderboard': <GlobalLeaderboardEntry>[], 'userRanking': null};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _allDataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 3,
                ),
              ),
            );
          }

          final leaderboardData =
              snapshot.data!['leaderboard'] as List<GlobalLeaderboardEntry>;
          return _buildLeaderboardContent(leaderboardData);
        },
      ),
    );
  }

  Widget _buildLeaderboardContent(List<GlobalLeaderboardEntry> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(AppConstants.largeSpacing),
          padding: const EdgeInsets.all(AppConstants.extraLargeSpacing),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.largeSpacing),
              Text(
                AppLocalizations.of(context)!.noEntriesYet,
                style: TextThemeManager.screenTitle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // User ranking info section (only show if not in top 10)
        if (_userRanking != null && !_userRanking!.isInTopTen)
          _buildUserRankingCard(_userRanking!),

        // Top entries list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppConstants.mediumSpacing),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final e = entries[index];
              final rank = index + 1;
              final rankColor = _getRankColor(context, rank);
              final isUserEntry = _isUserEntry(e);

              return _buildLeaderboardEntry(
                entry: e,
                rank: rank,
                rankColor: rankColor,
                isUserEntry: isUserEntry,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardEntry({
    required GlobalLeaderboardEntry entry,
    required int rank,
    required Color rankColor,
    required bool isUserEntry,
  }) {
    Widget entryWidget = Column(
      children: [
        if (isUserEntry) _buildShimmerUserScoreCard(),
        isUserEntry
            ? AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shimmer effect for user entry
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                                stops: [
                                  (_shimmerController.value - 0.3).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                  _shimmerController.value,
                                  (_shimmerController.value + 0.3).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Main content
                      Row(
                        children: [
                          // Rank badge with special styling for user
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$rank',
                                style: TextThemeManager.subtitleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Player info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.name,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          letterSpacing: 0.3,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      _flagEmoji(entry.countryCode),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Score pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.15),
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${entry.score}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Glow effect for user entry
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.8,
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
            : Container(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Rank badge
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [rankColor, rankColor.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: rankColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextThemeManager.subtitleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Player info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.name,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: 0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _flagEmoji(entry.countryCode),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Score pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          rankColor.withValues(alpha: 0.1),
                          rankColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: rankColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${entry.score}',
                      style: TextStyle(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );

    return entryWidget;
  }

  bool _isUserEntry(GlobalLeaderboardEntry entry) {
    if (_userName == null || _userCountryCode == null) {
      return false;
    }

    // Check if this entry matches the user's profile info (name and country code)
    return entry.name == _userName && entry.countryCode == _userCountryCode;
  }

  Widget _buildUserRankingCard(UserRankingInfo userRanking) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.mediumSpacing),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // User icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // User ranking info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.yourRanking,
                  style: TextThemeManager.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userRanking.rankDisplay,
                  style: TextThemeManager.screenTitle.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Score badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              '${userRanking.leaderboardScore}',
              style: TextThemeManager.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBars.leaderboardAppBar(context: context, title: widget.title);
  }

  Color _getRankColor(BuildContext context, int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _flagEmoji(String countryCode) {
    final upper = countryCode.toUpperCase();
    if (upper.length != 2) return '🏳️';
    const int base = 0x1F1E6;
    final int first = base + (upper.codeUnitAt(0) - 65);
    final int second = base + (upper.codeUnitAt(1) - 65);
    return String.fromCharCode(first) + String.fromCharCode(second);
  }

  Widget _buildShimmerUserScoreCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _starController]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Enhanced shimmer effect covering the entire container
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.4),
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      stops: [
                        (_shimmerController.value - 0.4).clamp(0.0, 1.0),
                        (_shimmerController.value - 0.2).clamp(0.0, 1.0),
                        _shimmerController.value,
                        (_shimmerController.value + 0.2).clamp(0.0, 1.0),
                        (_shimmerController.value + 0.4).clamp(0.0, 1.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale:
                        0.8 +
                        (0.2 *
                            (0.5 +
                                0.5 *
                                    math.sin(
                                      _starController.value * 2 * math.pi,
                                    ))),
                    child: Icon(
                      Icons.star_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.thisIsYourScore,
                    style: TextThemeManager.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform.scale(
                    scale:
                        0.8 +
                        (0.2 *
                            (0.5 +
                                0.5 *
                                    math.sin(
                                      _starController.value * 2 * math.pi,
                                    ))),
                    child: Icon(
                      Icons.star_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
