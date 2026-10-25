import 'package:flutter/material.dart';

class TextThemeManager {
  // Font ailesi
  static const String fontFamily = 'Poppins';

  // Başlık stilleri
  static TextStyle get appTitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get screenTitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get appBarTitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get sectionTitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get cardTitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // Alt başlık stilleri
  static TextStyle get subtitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get subtitleMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Gövde metin stilleri
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  // Buton stilleri
  static TextStyle get buttonLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get buttonMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get buttonSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // Oyun özel stilleri
  static TextStyle get gameNumber => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get gameScore => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );

  // Headline stilleri
  static TextStyle get headlineSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get titleSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get gameLabel => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get gameSlotNumber => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get gameSlotValue => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // Açıklama stilleri
  static TextStyle get description => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static TextStyle get caption => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  // Uyarı ve hata stilleri
  static TextStyle get warning => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get error => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Renkli stiller oluşturma metodları
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withValues(alpha: opacity));
  }

  // Tema renklerine göre stiller
  static TextStyle primary(TextStyle style, BuildContext context) {
    return withColor(style, Theme.of(context).colorScheme.primary);
  }

  static TextStyle onPrimary(TextStyle style, BuildContext context) {
    return withColor(style, Theme.of(context).colorScheme.onPrimary);
  }

  static TextStyle onSurface(TextStyle style, BuildContext context) {
    return withColor(style, Theme.of(context).colorScheme.onSurface);
  }

  static TextStyle onSurfaceVariant(TextStyle style, BuildContext context) {
    return withColor(style, Theme.of(context).colorScheme.onSurfaceVariant);
  }

  static TextStyle errorColor(TextStyle style, BuildContext context) {
    return withColor(style, Theme.of(context).colorScheme.error);
  }

  // Özel kullanım metodları
  static TextStyle appTitlePrimary(BuildContext context) {
    return primary(appTitle, context);
  }

  static TextStyle screenTitlePrimary(BuildContext context) {
    return primary(screenTitle, context);
  }

  static TextStyle appBarTitleOnPrimary(BuildContext context) {
    return onPrimary(appBarTitle, context);
  }

  static TextStyle bodyOnSurface(BuildContext context) {
    return onSurface(bodyMedium, context);
  }

  static TextStyle descriptionOnSurface(BuildContext context) {
    return onSurface(description, context);
  }

  static TextStyle gameNumberWhite() {
    return withColor(gameNumber, Colors.white);
  }

  static TextStyle gameScorePrimary(BuildContext context) {
    return primary(gameScore, context);
  }

  static TextStyle gameLabelOnSurface(BuildContext context) {
    return onSurface(gameLabel, context);
  }

  static TextStyle gameSlotNumberOnSurface(BuildContext context) {
    return withOpacity(onSurface(gameSlotNumber, context), 0.7);
  }

  static TextStyle gameSlotValuePrimary(BuildContext context) {
    return primary(gameSlotValue, context);
  }

  static TextStyle warningOnSurface(BuildContext context) {
    return onSurface(warning, context);
  }

  static TextStyle errorOnSurface(BuildContext context) {
    return onSurface(error, context);
  }

  static TextStyle buttonOnPrimary(BuildContext context) {
    return onPrimary(buttonLarge, context);
  }
}
