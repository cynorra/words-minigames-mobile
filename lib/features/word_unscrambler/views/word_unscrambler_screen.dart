import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicko_app/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/game_screen_base.dart';
import '../providers/word_unscrambler_provider.dart';

class WordUnscramblerScreen extends StatelessWidget {
  const WordUnscramblerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) {
        final locale = Localizations.localeOf(ctx).languageCode;
        final provider = WordUnscramblerProvider();
        provider.init(locale);
        return provider;
      },
      child: const _WordUnscramblerView(),
    );
  }
}

class _WordUnscramblerView extends StatelessWidget {
  const _WordUnscramblerView();

  @override
  Widget build(BuildContext context) {
    return Consumer<WordUnscramblerProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final currentWord = provider.currentWordItem;

        GameResult? gameResult;
        if (provider.isGameOver) {
          gameResult = GameResult(
            isWin: provider.score > 0,
            score: provider.score,
            title: provider.score > 0
                ? AppLocalizations.of(context)!.congratulations
                : AppLocalizations.of(context)!.gameOver,
            subtitle: '${provider.score} Puan!',
            lossReason: 'Süre doldu! Doğru kelime: ${currentWord?.word ?? ""}',
          );
        }

        return GameScreenBase(
          title: 'word_unscrambler',
          descriptionKey: 'word_unscrambler_description',
          gameId: 'word_unscrambler',
          gameResult: gameResult,
          showCongratsOnWin: true,
          onTryAgain: () {
            final locale = Localizations.localeOf(context).languageCode;
            provider.init(locale);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.mediumSpacing),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Top status bar (Round, Timer, Score)
                _buildStatusBar(context, provider, isDark),
                const SizedBox(height: 24),

                // Category & Hint Section
                _buildClueCard(context, provider, isDark),
                const Spacer(),

                // Guess Slots (Word Assembly Area)
                _buildGuessSlots(context, provider, isDark),
                const Spacer(),

                // Scrambled Letters Selection Grid
                _buildLetterGrid(context, provider, isDark),
                const SizedBox(height: 20),

                // Controls (Undo, Clear, Hint)
                _buildBottomControls(context, provider, isDark),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBar(BuildContext context, WordUnscramblerProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceElevated : AppTheme.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.flag_circle, size: 20, color: isDark ? AppTheme.darkSecondary : AppTheme.lightSecondary),
              const SizedBox(width: 6),
              Text(
                'Tur: ${provider.round}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 20,
                color: provider.timeLeft <= 5 ? AppTheme.darkError : (isDark ? AppTheme.darkAccent : AppTheme.lightAccent),
              ),
              const SizedBox(width: 6),
              Text(
                '${provider.timeLeft}s',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: provider.timeLeft <= 5 ? AppTheme.darkError : null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.stars_rounded, size: 20, color: AppTheme.goldYellow),
              const SizedBox(width: 6),
              Text(
                '${provider.score}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClueCard(BuildContext context, WordUnscramblerProvider provider, bool isDark) {
    final item = provider.currentWordItem;
    if (item == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: provider.isSuccessAnim
              ? AppTheme.vividGreen
              : (isDark ? const Color(0xFF2A3042) : const Color(0xFFE2E8F0)),
          width: provider.isSuccessAnim ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkSecondary : AppTheme.lightSecondary).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.category.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isDark ? AppTheme.darkSecondary : AppTheme.lightSecondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            provider.showHint ? item.clue : 'Karışık harflerden doğru kelimeyi oluştur!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontStyle: provider.showHint ? FontStyle.italic : FontStyle.normal,
              color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuessSlots(BuildContext context, WordUnscramblerProvider provider, bool isDark) {
    final targetLength = provider.currentWordItem?.word.length ?? 0;
    final guess = provider.currentGuess;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: List.generate(targetLength, (index) {
        final hasLetter = index < guess.length;
        final letter = hasLetter ? guess[index] : '';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            color: hasLetter
                ? (provider.isSuccessAnim
                    ? AppTheme.vividGreen.withValues(alpha: 0.25)
                    : (isDark ? AppTheme.darkSurfaceElevated : AppTheme.lightSurfaceElevated))
                : (isDark ? const Color(0xFF131622) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: provider.isSuccessAnim
                  ? AppTheme.vividGreen
                  : (hasLetter
                      ? (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                      : (isDark ? const Color(0xFF2A3042) : const Color(0xFFCBD5E1))),
              width: hasLetter ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLetterGrid(BuildContext context, WordUnscramblerProvider provider, bool isDark) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: List.generate(provider.scrambledLetters.length, (index) {
        final isSelected = provider.selectedIndices.contains(index);
        final letter = provider.scrambledLetters[index];

        return GestureDetector(
          onTap: () => provider.selectLetter(index),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: isSelected ? 0.25 : 1.0,
            child: Container(
              width: 52,
              height: 54,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? null
                    : LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF252B3E), const Color(0xFF1B1F2D)]
                            : [Colors.white, const Color(0xFFE2E8F0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isSelected ? (isDark ? const Color(0xFF1E2333) : const Color(0xFFE2E8F0)) : null,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary).withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkOnBackground : AppTheme.lightOnBackground,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomControls(BuildContext context, WordUnscramblerProvider provider, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Hint Button
        IconButton.filledTonal(
          onPressed: provider.showHint ? null : provider.revealHint,
          icon: const Icon(Icons.lightbulb_outline),
          tooltip: 'İpucu (-5sn)',
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.goldYellow.withValues(alpha: 0.15),
            foregroundColor: AppTheme.goldYellow,
          ),
        ),
        // Clear Button
        IconButton.filledTonal(
          onPressed: provider.selectedIndices.isEmpty ? null : provider.clearSelection,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Temizle',
        ),
        // Undo / Backspace Button
        IconButton.filledTonal(
          onPressed: provider.selectedIndices.isEmpty ? null : provider.removeLastLetter,
          icon: const Icon(Icons.backspace_outlined),
          tooltip: 'Sil',
        ),
      ],
    );
  }
}
