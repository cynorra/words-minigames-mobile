import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _showRemoveAdsDialogKey = 'show_remove_ads_dialog';
  bool _isOnboardingCompleted = false;
  bool _isLoading = true;
  bool _shouldShowRemoveAdsDialog = false;

  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isLoading => _isLoading;
  bool get shouldShowOnboarding => !_isOnboardingCompleted;
  bool get shouldShowRemoveAdsDialog => _shouldShowRemoveAdsDialog;

  OnboardingProvider() {
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;
      _shouldShowRemoveAdsDialog =
          prefs.getBool(_showRemoveAdsDialogKey) ?? false;
    } catch (e) {
      // If there's an error, default to showing onboarding
      _isOnboardingCompleted = false;
      _shouldShowRemoveAdsDialog = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);
      await prefs.setBool(_showRemoveAdsDialogKey, true);
      _isOnboardingCompleted = true;
      _shouldShowRemoveAdsDialog = true;
      notifyListeners();
    } catch (e) {
      // Handle error silently in production
    }
  }

  Future<void> dismissRemoveAdsDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_showRemoveAdsDialogKey, false);
      _shouldShowRemoveAdsDialog = false;
      notifyListeners();
    } catch (e) {
      // Handle error silently in production
    }
  }

  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompletedKey);
      await prefs.remove(_showRemoveAdsDialogKey);
      _isOnboardingCompleted = false;
      _shouldShowRemoveAdsDialog = false;
      notifyListeners();
    } catch (e) {
      // Handle error silently in production
    }
  }
}
