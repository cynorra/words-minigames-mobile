import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../models/feedback_data.dart';
import '../../../core/services/email_service.dart';

class FeedbackProvider extends ChangeNotifier {
  FeedbackData _feedbackData = const FeedbackData(
    category: 'bug',
    title: '',
    description: '',
    userEmail: '',
  );

  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isSuccess = false;
  bool _hasValidationError = false;

  // Getters
  FeedbackData get feedbackData => _feedbackData;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;
  bool get hasValidationError => _hasValidationError;
  bool get isFormValid => _feedbackData.isValid;

  /// Get localized category names
  static List<String> getCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.feedbackCategoryBug,
      l10n.feedbackCategoryFeature,
      l10n.feedbackCategoryImprovement,
      l10n.feedbackCategoryGeneral,
    ];
  }

  /// Get category key from localized name
  static String getCategoryKey(String localizedName, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (localizedName == l10n.feedbackCategoryBug) return 'bug';
    if (localizedName == l10n.feedbackCategoryFeature) return 'feature';
    if (localizedName == l10n.feedbackCategoryImprovement) return 'improvement';
    if (localizedName == l10n.feedbackCategoryGeneral) return 'general';
    return 'general'; // default
  }

  /// Get localized name from category key
  static String getCategoryName(String categoryKey, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (categoryKey) {
      case 'bug':
        return l10n.feedbackCategoryBug;
      case 'feature':
        return l10n.feedbackCategoryFeature;
      case 'improvement':
        return l10n.feedbackCategoryImprovement;
      case 'general':
        return l10n.feedbackCategoryGeneral;
      default:
        return l10n.feedbackCategoryGeneral;
    }
  }

  /// Updates the feedback data
  void updateFeedbackData(FeedbackData newData) {
    _feedbackData = newData;
    _clearError();
    notifyListeners();
  }

  /// Updates specific fields
  void updateCategory(String category) {
    _feedbackData = _feedbackData.copyWith(category: category);
    _clearError();
    _setValidationError(false);
    notifyListeners();
  }

  void updateTitle(String title) {
    _feedbackData = _feedbackData.copyWith(title: title);
    _clearError();
    _setValidationError(false);
    notifyListeners();
  }

  void updateDescription(String description) {
    _feedbackData = _feedbackData.copyWith(description: description);
    _clearError();
    _setValidationError(false);
    notifyListeners();
  }

  void updateUserEmail(String userEmail) {
    _feedbackData = _feedbackData.copyWith(userEmail: userEmail);
    _clearError();
    _setValidationError(false);
    notifyListeners();
  }

  /// Submits feedback
  Future<bool> submitFeedback() async {
    if (!_feedbackData.isValid) {
      _setValidationError(true);
      return false;
    }

    _setSubmitting(true);
    _clearError();

    try {
      final success = await EmailService.sendFeedback(
        category: _feedbackData.category,
        title: _feedbackData.title,
        description: _feedbackData.description,
        userEmail: _feedbackData.userEmail,
      );

      _setSubmitting(false);

      if (success) {
        _setSuccess(true);
        _resetForm();
        return true;
      } else {
        _setError('Failed to send feedback. Please try again.');
        return false;
      }
    } catch (e) {
      _setSubmitting(false);
      _setError('Error sending feedback: $e');
      return false;
    }
  }

  /// Resets the form to initial state
  void resetForm() {
    _resetForm();
    notifyListeners();
  }

  /// Clears error message
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Private methods
  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isSuccess = false;
    notifyListeners();
  }

  void _setSuccess(bool success) {
    _isSuccess = success;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _isSuccess = false;
  }

  void _setValidationError(bool hasError) {
    _hasValidationError = hasError;
  }

  void _resetForm() {
    _feedbackData = const FeedbackData(
      category: 'bug',
      title: '',
      description: '',
      userEmail: '',
    );
    _clearError();
    _setValidationError(false);
  }
}
