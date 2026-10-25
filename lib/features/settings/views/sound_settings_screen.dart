import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/sound_settings_provider.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../core/utils/sound_utils.dart';
import '../../../shared/widgets/app_bars.dart';

class SoundSettingsScreen extends StatelessWidget {
  const SoundSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Consumer<SoundSettingsProvider>(
        builder: (context, soundProvider, _) {
          if (soundProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: AppConstants.largeSpacing),
                  _buildSoundToggle(context, soundProvider),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState:
                        soundProvider.soundEnabled
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                    firstChild: _buildSoundsDisabledMessage(context),
                    secondChild: Column(
                      children: [
                        _buildEffectsVolume(context, soundProvider),
                        const SizedBox(height: AppConstants.largeSpacing),
                        _buildTestSection(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBars.settingsAppBar(
      context: context,
      title: AppLocalizations.of(context)!.soundSettings,
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              Icons.volume_up_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppConstants.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.appSounds,
                  style: TextThemeManager.sectionTitle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.appSoundsDescription,
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

  Widget _buildSoundToggle(
    BuildContext context,
    SoundSettingsProvider provider,
  ) {
    return _settingsCard(
      context,
      child: Row(
        children: [
          _iconBadge(context, Icons.volume_mute_rounded),
          const SizedBox(width: AppConstants.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.sounds,
                  style: TextThemeManager.subtitleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.soundEnabled
                      ? AppLocalizations.of(context)!.soundsOn
                      : AppLocalizations.of(context)!.soundsOff,
                  style: TextThemeManager.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: provider.soundEnabled,
            onChanged: (v) => provider.setSoundEnabled(v),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectsVolume(
    BuildContext context,
    SoundSettingsProvider provider,
  ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return _settingsCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBadge(context, Icons.graphic_eq_rounded),
              const SizedBox(width: AppConstants.mediumSpacing),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.effectsVolume,
                  style: TextThemeManager.subtitleMedium.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(provider.effectsVolume * 100).round()}%',
                style: TextThemeManager.bodySmall.copyWith(
                  color: onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Row(
            children: [
              Icon(
                Icons.volume_down_rounded,
                color: onSurface.withValues(alpha: 0.6),
              ),
              Expanded(
                child: Slider(
                  value: provider.effectsVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged:
                      provider.soundEnabled
                          ? (v) => provider.setEffectsVolume(v)
                          : null,
                ),
              ),
              Icon(
                Icons.volume_up_rounded,
                color: onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection(BuildContext context) {
    return _settingsCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBadge(context, Icons.music_note_rounded),
              const SizedBox(width: AppConstants.mediumSpacing),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.soundTest,
                  style: TextThemeManager.subtitleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => SoundUtils.playBlinkSound(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.mediumSpacing,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.playSampleSound,
                style: TextThemeManager.subtitleMedium.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: child,
      ),
    );
  }

  Widget _buildSoundsDisabledMessage(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.volume_off_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          Text(
            AppLocalizations.of(context)!.soundsOff,
            style: TextThemeManager.subtitleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            AppLocalizations.of(context)!.appSoundsDescription,
            style: TextThemeManager.bodySmall.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _iconBadge(BuildContext context, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary),
    );
  }
}
