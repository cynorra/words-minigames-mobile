import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicko_app/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/game_screen_base.dart';
import '../models/word_guess_model.dart';
import '../providers/word_guess_provider.dart';

class WordGuessScreen extends StatelessWidget {
  const WordGuessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) {
        final locale = Localizations.localeOf(ctx).languageCode;
        final provider = WordGuessProvider();
        provider.init(locale);
        return provider;
      },
      child: const _WordGuessView(),
    );
  }
}

class _WordGuessView extends StatelessWidget {
  const _WordGuessView();

  @override
  Widget build(BuildContext context) {
    return Consumer<WordGuessProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        GameResult? gameResult;
        if (provider.isGameOver) {
          gameResult = GameResult(
            isWin: provider.isWin,
            score: provider.score,
            title: provider.isWin
                ? AppLocalizations.of(context)!.congratulations
                : AppLocalizations.of(context)!.gameOver,
            subtitle: provider.isWin
                ? '${provider.guesses.length}. denemede buldunuz! (+${(WordGuessProvider.maxAttempts - provider.guesses.length + 1) * 20} Puan)'
                : 'Doğru kelime: ${provider.targetWord}',
            lossReason: provider.isWin ? null : 'Deneme hakkınız tükendi.',
          );
        }

        return GameScreenBase(
          title: 'word_guess',
          descriptionKey: 'word_guess_description',
          gameId: 'word_guess',
          gameResult: gameResult,
          showCongratsOnWin: true,
          onTryAgain: () {
            provider.reset();
          },
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Grid of 6 attempts x 5 letters
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 5 / 6,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildGrid(context, provider, isDark),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Virtual Keyboard
              _buildKeyboard(context, provider, isDark),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, WordGuessProvider provider, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(WordGuessProvider.maxAttempts, (row) {
        return Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(WordGuessProvider.wordLength, (col) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildTile(context, provider, row, col, isDark),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildTile(BuildContext context, WordGuessProvider provider, int row, int col, bool isDark) {
    String letter = '';
    LetterState state = LetterState.empty;

    if (row < provider.guesses.length) {
      letter = provider.guesses[row][col];
      state = provider.getLetterState(row, col);
    } else if (row == provider.guesses.length) {
      if (col < provider.currentInput.length) {
        letter = provider.currentInput[col];
        state = LetterState.initial;
      }
    }

    Color bgColor;
    Color borderColor;
    Color textColor = Colors.white;

    switch (state) {
      case LetterState.correct:
        bgColor = AppTheme.vividGreen;
        borderColor = AppTheme.vividGreen;
        break;
      case LetterState.present:
        bgColor = AppTheme.darkAccent;
        borderColor = AppTheme.darkAccent;
        break;
      case LetterState.absent:
        bgColor = isDark ? const Color(0xFF252A3D) : const Color(0xFF94A3B8);
        borderColor = Colors.transparent;
        break;
      case LetterState.initial:
        bgColor = isDark ? AppTheme.darkSurfaceElevated : AppTheme.lightSurfaceElevated;
        borderColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;
        textColor = isDark ? Colors.white : Colors.black87;
        break;
      case LetterState.empty:
        bgColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
        borderColor = isDark ? const Color(0xFF2A3042) : const Color(0xFFE2E8F0);
        textColor = isDark ? Colors.white : Colors.black87;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: state == LetterState.initial ? 2 : 1),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard(BuildContext context, WordGuessProvider provider, bool isDark) {
    const row1 = ['E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'A', 'S'];
    const row2 = ['D', 'F', 'G', 'H', 'J', 'K', 'L', 'Z', 'C', 'V'];
    const row3 = ['B', 'N', 'M'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          _buildKeyRow(row1, provider, isDark),
          const SizedBox(height: 6),
          _buildKeyRow(row2, provider, isDark),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Enter Key
              _buildSpecialKey('ENTER', isDark, () => provider.submitGuess(), flex: 3),
              const SizedBox(width: 4),
              ...row3.map((k) => Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildKey(k, provider, isDark),
                    ),
                  )),
              const SizedBox(width: 4),
              // Backspace Key
              _buildSpecialKey('⌫', isDark, () => provider.backspace(), flex: 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys, WordGuessProvider provider, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildKey(key, provider, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey(String key, WordGuessProvider provider, bool isDark) {
    final state = provider.getKeyState(key);
    Color bgColor;
    Color textColor = isDark ? Colors.white : Colors.black87;

    switch (state) {
      case LetterState.correct:
        bgColor = AppTheme.vividGreen;
        textColor = Colors.white;
        break;
      case LetterState.present:
        bgColor = AppTheme.darkAccent;
        textColor = Colors.white;
        break;
      case LetterState.absent:
        bgColor = isDark ? const Color(0xFF1F2433) : const Color(0xFFCBD5E1);
        textColor = Colors.grey;
        break;
      default:
        bgColor = isDark ? AppTheme.darkSurfaceElevated : AppTheme.lightSurfaceElevated;
        break;
    }

    return GestureDetector(
      onTap: () => provider.inputLetter(key),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            key,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String label, bool isDark, VoidCallback onTap, {int flex = 2}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D354B) : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
