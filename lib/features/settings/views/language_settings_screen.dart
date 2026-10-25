import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/constants/supported_locales.dart';
import '../../../shared/widgets/app_bars.dart';

/// Data class for language information
/// Immutable and efficient for performance
class LanguageData {
  final String title;
  final String flag;
  final String languageCode;
  final bool isSelected;

  const LanguageData(this.title, this.flag, this.languageCode, this.isSelected);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageData &&
        other.title == title &&
        other.flag == flag &&
        other.languageCode == languageCode &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        flag.hashCode ^
        languageCode.hashCode ^
        isSelected.hashCode;
  }
}

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Language Header
                      _buildLanguageHeader(context),
                      const SizedBox(height: AppConstants.largeSpacing),

                      // Language Options
                      _buildLanguageOptions(context, languageProvider),

                      const SizedBox(height: AppConstants.largeSpacing),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBars.settingsAppBar(
      context: context,
      title: AppLocalizations.of(context)!.language,
    );
  }

  Widget _buildLanguageHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
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
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.language_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectLanguage,
                  style: TextThemeManager.sectionTitle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.choosePreferredLanguage,
                  style: TextThemeManager.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOptions(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final languages = _getSupportedLanguages(languageProvider);

    return Column(
      children: List.generate(languages.length, (index) {
        final language = languages[index];
        return Column(
          children: [
            _buildLanguageOption(
              context,
              languageProvider,
              language.title,
              language.flag,
              language.languageCode,
              language.isSelected,
            ),
            if (index < languages.length - 1)
              const SizedBox(height: AppConstants.mediumSpacing),
          ],
        );
      }),
    );
  }

  /// Returns the list of supported languages with their current selection state
  /// This method is optimized for performance and maintainability
  List<LanguageData> _getSupportedLanguages(LanguageProvider languageProvider) {
    // Language display names mapping
    // Ordered by popularity and market potential
    const Map<String, String> languageDisplayNames = {
      // Tier 1: Global Languages (Most Popular)
      'en': 'English',
      'tr': 'Türkçe',
      'es': 'Español',
      'hi': 'हिंदी',
      'ar': 'العربية',

      // Tier 2: Major European Markets
      'de': 'Deutsch',
      'fr': 'Français',
      'it': 'Italiano',
      'ru': 'Русский',

      // Tier 3: Emerging Markets
      'pt_BR': 'Português',
      'id': 'Bahasa Indonesia',
    };

    // Language flag emojis mapping
    // Ordered by popularity and market potential
    const Map<String, String> languageFlags = {
      // Tier 1: Global Languages (Most Popular)
      'en': '🇺🇸',
      'tr': '🇹🇷',
      'es': '🇪🇸',
      'hi': '🇮🇳',
      'ar': '🇸🇦',

      // Tier 2: Major European Markets
      'de': '🇩🇪',
      'fr': '🇫🇷',
      'it': '🇮🇹',
      'ru': '🇷🇺',

      // Tier 3: Emerging Markets
      'pt_BR': '🇧🇷',
      'id': '🇮🇩',
    };

    return SupportedLocales.locales.map((locale) {
      final languageCode =
          locale.countryCode != null
              ? '${locale.languageCode}_${locale.countryCode}'
              : locale.languageCode;

      final displayName =
          languageDisplayNames[languageCode] ?? locale.languageCode;
      final flag = languageFlags[languageCode] ?? '🌐';

      // Check if this locale is currently selected
      bool isSelected = false;
      if (locale.languageCode == languageProvider.currentLocale.languageCode) {
        if (locale.countryCode == null) {
          isSelected = languageProvider.currentLocale.countryCode == null;
        } else {
          isSelected =
              locale.countryCode == languageProvider.currentLocale.countryCode;
        }
      }

      return LanguageData(displayName, flag, languageCode, isSelected);
    }).toList();
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LanguageProvider languageProvider,
    String title,
    String flag,
    String languageCode,
    bool isSelected,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      decoration: _buildLanguageOptionDecoration(context, isSelected),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => languageProvider.changeLanguage(languageCode),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mediumSpacing),
            child: Row(
              children: [
                _buildFlagContainer(context, flag, isSelected),
                const SizedBox(width: AppConstants.mediumSpacing),
                _buildLanguageInfo(context, title, isSelected),
                if (isSelected) _buildSelectionIndicator(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the decoration for language option container
  BoxDecoration _buildLanguageOptionDecoration(
    BuildContext context,
    bool isSelected,
  ) {
    return BoxDecoration(
      gradient:
          isSelected
              ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                ],
              )
              : null,
      color: isSelected ? null : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        width: isSelected ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
          blurRadius: isSelected ? 12 : 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Builds the flag container widget
  Widget _buildFlagContainer(
    BuildContext context,
    String flag,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
          width: 1,
        ),
      ),
      child: Text(flag, style: const TextStyle(fontSize: 24)),
    );
  }

  /// Builds the language info widget
  Widget _buildLanguageInfo(
    BuildContext context,
    String title,
    bool isSelected,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextThemeManager.subtitleMedium.copyWith(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the selection indicator widget
  Widget _buildSelectionIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
    );
  }
}
