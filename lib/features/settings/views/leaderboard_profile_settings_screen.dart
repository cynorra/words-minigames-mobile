// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:quicko_app/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_theme_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/services/leaderboard_profile_service.dart';
import '../../../shared/widgets/app_bars.dart';

class LeaderboardProfileSettingsScreen extends StatefulWidget {
  const LeaderboardProfileSettingsScreen({super.key});

  @override
  State<LeaderboardProfileSettingsScreen> createState() =>
      _LeaderboardProfileSettingsScreenState();
}

class _LeaderboardProfileSettingsScreenState
    extends State<LeaderboardProfileSettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String _countryCode = 'TR';
  String _countryDisplay = 'Türkiye';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = LeaderboardProfileService();
    final name = await service.getName();
    final code = await service.getCountryCode();
    setState(() {
      _nameController.text = name ?? '';
      _countryCode = code ?? 'TR';
      _countryDisplay = _countryNameFromCode(_countryCode);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<bool> _confirmProfileSave() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
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
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.areYouSure,
                                  style: TextThemeManager.subtitleMedium
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.profileChangeWarning,
                                  style: TextThemeManager.bodyMedium.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.profileChangeDescription,
                            style: TextThemeManager.bodyMedium.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.cancel,
                                      style: TextThemeManager.bodyMedium
                                          .copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.save,
                                      style: TextThemeManager.bodyMedium
                                          .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBars.settingsAppBar(
        context: context,
        title: AppLocalizations.of(context)!.leaderboardProfile,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    // Main content with scroll
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.mediumSpacing,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.name,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                maxLength: 16,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.nameRequired;
                                  }
                                  if (v.trim().length < 2) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.minimumTwoCharacters;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: AppConstants.mediumSpacing,
                              ),
                              InkWell(
                                onTap: () {
                                  final double halfHeight =
                                      MediaQuery.of(context).size.height * 0.5;
                                  showCountryPicker(
                                    context: context,
                                    showPhoneCode: false,
                                    countryListTheme: CountryListThemeData(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.surface,
                                      bottomSheetHeight: halfHeight,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      textStyle: TextThemeManager.bodyMedium
                                          .copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                      inputDecoration: InputDecoration(
                                        labelText:
                                            AppLocalizations.of(
                                              context,
                                            )!.searchCountry,
                                        prefixIcon: const Icon(
                                          Icons.search_rounded,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onSelect: (c) {
                                      setState(() {
                                        _countryCode = c.countryCode;
                                        _countryDisplay = c.name;
                                      });
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText:
                                        AppLocalizations.of(context)!.country,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _flagEmoji(_countryCode),
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _countryDisplay,
                                          style: TextThemeManager.bodyMedium
                                              .copyWith(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Fixed bottom button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.darkPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            final bool confirmed = await _confirmProfileSave();
                            if (!confirmed) return;
                            await LeaderboardProfileService().saveProfile(
                              name: _nameController.text.trim(),
                              countryCode: _countryCode,
                            );
                            if (mounted) {
                              AppRouter.pop(context);
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.save,
                            style: TextThemeManager.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  String _countryNameFromCode(String code) {
    try {
      // country_picker doesn't expose lookup by code directly here; fallback to code itself
      return code.toUpperCase();
    } catch (_) {
      return code.toUpperCase();
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
}
