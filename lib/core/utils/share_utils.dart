import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../shared/widgets/achievement_image_generator.dart';
import '../../shared/models/leaderboard_entry.dart';

class ShareUtils {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  /// Achievement görüntüsünü paylaş
  static Future<void> shareAchievementImage({
    required List<LeaderboardEntry> entries,
    required int totalGames,
    required int highestScore,
    required double averageScore,
  }) async {
    try {
      // Sadece üst alanı içeren widget'ı oluştur
      final achievementWidget = AchievementImageGenerator(
        entries: entries,
        totalGames: totalGames,
        highestScore: highestScore,
        averageScore: averageScore,
        showTopGames: false, // SADECE ÜST ALAN
      );

      // Screenshot al
      final Uint8List imageBytes = await _screenshotController
          .captureFromWidget(
            achievementWidget,
            delay: const Duration(milliseconds: 100),
            pixelRatio: 3.0,
          );

      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/achievement_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(imageBytes);

      // Paylaş
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Check out my gaming achievements! 🎮🏆');
    } catch (e) {
      // Handle error silently in production
      rethrow;
    }
  }

  /// Achievement önizlemesini göster
  static void showAchievementPreview({
    required BuildContext context,
    required List<LeaderboardEntry> entries,
    required int totalGames,
    required int highestScore,
    required double averageScore,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            height: 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AchievementImageGenerator(
                entries: entries,
                totalGames: totalGames,
                highestScore: highestScore,
                averageScore: averageScore,
                showTopGames: false, // Önizlemede de sadece üst alan
              ),
            ),
          ),
        );
      },
    );
  }
}
