import 'dart:io';
import '../services/in_app_purchase_service.dart';
import 'package:flutter/foundation.dart';
import '../../l10n/app_localizations.dart';

enum PurchaseErrorType {
  networkError,
  paymentMethodError,
  userCancelled,
  productNotFound,
  alreadyOwned,
  storeNotAvailable,
  insufficientFunds,
  unknownError,
  restoreFailed,
  noPurchasesFound,
}

class PurchaseErrorInfo {
  final PurchaseErrorType type;
  final String? originalError;
  final String userFriendlyTitle;
  final String userFriendlyDescription;

  PurchaseErrorInfo({
    required this.type,
    this.originalError,
    required this.userFriendlyTitle,
    required this.userFriendlyDescription,
  });
}

class InAppPurchaseProvider extends ChangeNotifier {
  final InAppPurchaseService _purchaseService = InAppPurchaseService();

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  PurchaseErrorInfo? _purchaseErrorInfo;

  // Listeners for ad services to get real-time updates
  final List<VoidCallback> _adFreeStatusListeners = [];

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isAdFree => _purchaseService.isAdFree;
  bool get isSubscriptionActive => _purchaseService.isSubscriptionActive();
  DateTime? get subscriptionExpiry => _purchaseService.subscriptionExpiry;
  DateTime? get subscriptionStart => _purchaseService.subscriptionStart;
  DateTime? get lastPaymentDate => _purchaseService.lastPaymentDate;
  int get remainingDays => _purchaseService.getRemainingDays();
  bool get isPaymentDueSoon => _purchaseService.isPaymentDueSoon;
  int get subscriptionDuration => _purchaseService.getSubscriptionDuration();
  String get subscriptionStatusText =>
      _purchaseService.getSubscriptionStatusText();
  String? get errorMessage => _errorMessage;
  PurchaseErrorInfo? get purchaseErrorInfo => _purchaseErrorInfo;
  String? get lastPurchaseError => _purchaseService.lastPurchaseError;
  String? get lastPurchaseErrorCode => _purchaseService.lastPurchaseErrorCode;
  bool get isIOS => Platform.isIOS;

  InAppPurchaseProvider() {
    _initialize();
  }

  /// Classify error and create user-friendly error information
  PurchaseErrorInfo _classifyError(dynamic error, {bool isRestore = false}) {
    final errorString = error.toString().toLowerCase();

    if (isRestore) {
      if (errorString.contains('no purchases') ||
          errorString.contains('nothing to restore') ||
          errorString.contains('no previous purchases')) {
        return PurchaseErrorInfo(
          type: PurchaseErrorType.noPurchasesFound,
          originalError: error.toString(),
          userFriendlyTitle: 'No Previous Purchases Found',
          userFriendlyDescription:
              'We couldn\'t find any previous purchases to restore. Make sure you\'re signed in with the same Apple ID you used for the original purchase.',
        );
      }
      return PurchaseErrorInfo(
        type: PurchaseErrorType.restoreFailed,
        originalError: error.toString(),
        userFriendlyTitle: 'Restore Failed',
        userFriendlyDescription:
            'We couldn\'t restore your purchases. Please check your internet connection and try again.',
      );
    }

    // Network-related errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable')) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.networkError,
        originalError: error.toString(),
        userFriendlyTitle: 'Connection Problem',
        userFriendlyDescription:
            'Please check your internet connection and try again. A stable connection is required for purchases.',
      );
    }

    // Payment method errors
    if (errorString.contains('payment') ||
        errorString.contains('billing') ||
        errorString.contains('card') ||
        errorString.contains('declined')) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.paymentMethodError,
        originalError: error.toString(),
        userFriendlyTitle: 'Payment Method Issue',
        userFriendlyDescription:
            'There\'s an issue with your payment method. Please check your card details or try a different payment method.',
      );
    }

    // Insufficient funds
    if (errorString.contains('insufficient') ||
        errorString.contains('funds') ||
        errorString.contains('balance')) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.insufficientFunds,
        originalError: error.toString(),
        userFriendlyTitle: 'Insufficient Funds',
        userFriendlyDescription:
            'Your payment method doesn\'t have sufficient funds. Please add money to your account or use a different payment method.',
      );
    }

    // User cancelled
    if (errorString.contains('cancelled') ||
        errorString.contains('canceled') ||
        errorString.contains('user cancelled')) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.userCancelled,
        originalError: error.toString(),
        userFriendlyTitle: 'Purchase Cancelled',
        userFriendlyDescription:
            'You cancelled the purchase. You can try again anytime.',
      );
    }

    // Product not found
    if (errorString.contains('product') &&
        (errorString.contains('not found') ||
            errorString.contains('invalid'))) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.productNotFound,
        originalError: error.toString(),
        userFriendlyTitle: 'Product Not Available',
        userFriendlyDescription:
            'This product is temporarily unavailable. Please try again later or contact support if the issue persists.',
      );
    }

    // Already owned
    if (errorString.contains('already') &&
        (errorString.contains('owned') || errorString.contains('purchased'))) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.alreadyOwned,
        originalError: error.toString(),
        userFriendlyTitle: 'Already Purchased',
        userFriendlyDescription:
            'You already own this product. Try restoring your purchases if you\'re not seeing the benefits.',
      );
    }

    // Store not available
    if (errorString.contains('store') &&
        (errorString.contains('not available') ||
            errorString.contains('unavailable'))) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.storeNotAvailable,
        originalError: error.toString(),
        userFriendlyTitle: 'Store Unavailable',
        userFriendlyDescription:
            'The app store is temporarily unavailable. Please try again in a few minutes.',
      );
    }

    // Default unknown error
    return PurchaseErrorInfo(
      type: PurchaseErrorType.unknownError,
      originalError: error.toString(),
      userFriendlyTitle: 'Purchase Failed',
      userFriendlyDescription:
          'We couldn\'t complete your purchase. Please try again or check your payment method.',
    );
  }

  /// Static method to classify error with localized strings
  static PurchaseErrorInfo classifyErrorWithLocalization(
    dynamic error,
    AppLocalizations localizations, {
    bool isRestore = false,
  }) {
    final errorString = error.toString().toLowerCase();

    if (isRestore) {
      if (errorString.contains('no purchases') ||
          errorString.contains('nothing to restore') ||
          errorString.contains('no previous purchases')) {
        return PurchaseErrorInfo(
          type: PurchaseErrorType.noPurchasesFound,
          originalError: error.toString(),
          userFriendlyTitle: localizations.noPurchasesFound,
          userFriendlyDescription: localizations.noPurchasesFoundDescription,
        );
      }
      return PurchaseErrorInfo(
        type: PurchaseErrorType.restoreFailed,
        originalError: error.toString(),
        userFriendlyTitle: localizations.restoreFailed,
        userFriendlyDescription: localizations.restoreFailedDescription,
      );
    }

    // Network-related errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable')) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.networkError,
        originalError: error.toString(),
        userFriendlyTitle: localizations.connectionProblem,
        userFriendlyDescription: localizations.connectionProblemDescription,
      );
    }

    // Payment method errors (but not insufficient funds)
    if ((errorString.contains('payment') ||
            errorString.contains('billing') ||
            errorString.contains('card') ||
            errorString.contains('invalid')) &&
        !errorString.contains('insufficient') &&
        !errorString.contains('funds') &&
        !errorString.contains('declined')) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.paymentMethodError,
        originalError: error.toString(),
        userFriendlyTitle: localizations.paymentMethodIssue,
        userFriendlyDescription: localizations.paymentMethodIssueDescription,
      );
    }

    // Insufficient funds - check for various error patterns
    if (errorString.contains('insufficient') ||
        errorString.contains('funds') ||
        errorString.contains('balance') ||
        errorString.contains('not enough') ||
        errorString.contains('declined') ||
        errorString.contains('insufficient_funds') ||
        errorString.contains('payment_declined') ||
        errorString.contains('billing_error') ||
        errorString.contains(
          'error_7',
        ) || // Android billing error 7 - insufficient funds
        errorString.contains(
          'error_-2',
        ) || // iOS StoreKit error -2 - payment not allowed
        errorString.contains('store_kit_error') ||
        (errorString.contains('purchase_failed') &&
            errorString.contains('billing'))) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.insufficientFunds,
        originalError: error.toString(),
        userFriendlyTitle: localizations.insufficientFunds,
        userFriendlyDescription: localizations.insufficientFundsDescription,
      );
    }

    // User cancelled
    if (errorString.contains('cancelled') ||
        errorString.contains('canceled') ||
        errorString.contains('user cancelled')) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.userCancelled,
        originalError: error.toString(),
        userFriendlyTitle: localizations.purchaseCancelled,
        userFriendlyDescription: localizations.purchaseCancelledDescription,
      );
    }

    // Product not found
    if (errorString.contains('product') &&
        (errorString.contains('not found') ||
            errorString.contains('invalid'))) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.productNotFound,
        originalError: error.toString(),
        userFriendlyTitle: localizations.productNotAvailable,
        userFriendlyDescription: localizations.productNotAvailableDescription,
      );
    }

    // Already owned
    if (errorString.contains('already') &&
        (errorString.contains('owned') || errorString.contains('purchased'))) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.alreadyOwned,
        originalError: error.toString(),
        userFriendlyTitle: localizations.alreadyPurchased,
        userFriendlyDescription: localizations.alreadyPurchasedDescription,
      );
    }

    // Store not available
    if (errorString.contains('store') &&
        (errorString.contains('not available') ||
            errorString.contains('unavailable'))) {
      return PurchaseErrorInfo(
        type: PurchaseErrorType.storeNotAvailable,
        originalError: error.toString(),
        userFriendlyTitle: localizations.storeUnavailable,
        userFriendlyDescription: localizations.storeUnavailableDescription,
      );
    }

    // Default unknown error
    return PurchaseErrorInfo(
      type: PurchaseErrorType.unknownError,
      originalError: error.toString(),
      userFriendlyTitle: localizations.purchaseError,
      userFriendlyDescription: localizations.purchaseErrorDescription,
    );
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _purchaseService.initialize();
      _isInitialized = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize purchase service: $e';
      _purchaseErrorInfo = _classifyError(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// (removed) test mode toggle

  /// Purchase ad-free subscription
  Future<bool> purchaseAdFreeSubscription() async {
    if (!_isInitialized) {
      _errorMessage = 'Purchase service not initialized';
      _purchaseErrorInfo = PurchaseErrorInfo(
        type: PurchaseErrorType.storeNotAvailable,
        originalError: 'Purchase service not initialized',
        userFriendlyTitle: 'Store Unavailable',
        userFriendlyDescription:
            'The app store is temporarily unavailable. Please try again in a few minutes.',
      );
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _purchaseErrorInfo = null;
    // Clear any previous purchase errors
    _purchaseService.clearLastPurchaseError();
    notifyListeners();

    try {
      final success = await _purchaseService.purchaseAdFreeSubscription();

      if (success) {
        _errorMessage = null;
        _purchaseErrorInfo = null;
        // For iOS, ensure UI is updated after successful purchase
        if (Platform.isIOS) {
          // Small delay to ensure purchase status is properly updated
          await Future.delayed(const Duration(milliseconds: 500));
        }
        // Notify ad services that ad-free status has changed
        _notifyAdFreeStatusListeners();
        // Force UI refresh after successful purchase
        notifyListeners();
      } else {
        // Use detailed error from service if available, otherwise use generic message
        final detailedError =
            _purchaseService.lastPurchaseError ?? 'Purchase failed';
        _errorMessage = 'Failed to purchase subscription: $detailedError';
        _purchaseErrorInfo = _classifyError(detailedError);
      }

      return success;
    } catch (e) {
      _errorMessage = 'Purchase error: $e';
      _purchaseErrorInfo = _classifyError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    if (!_isInitialized) {
      _errorMessage = 'Purchase service not initialized';
      _purchaseErrorInfo = PurchaseErrorInfo(
        type: PurchaseErrorType.storeNotAvailable,
        originalError: 'Purchase service not initialized',
        userFriendlyTitle: 'Store Unavailable',
        userFriendlyDescription:
            'The app store is temporarily unavailable. Please try again in a few minutes.',
      );
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _purchaseErrorInfo = null;
    // Clear any previous purchase errors
    _purchaseService.clearLastPurchaseError();
    notifyListeners();

    try {
      final success = await _purchaseService.restorePurchases();

      if (success) {
        _errorMessage = null;
        _purchaseErrorInfo = null;
        // For iOS, ensure UI is updated after successful restoration
        if (Platform.isIOS) {
          // Small delay to ensure purchase status is properly updated
          await Future.delayed(const Duration(milliseconds: 500));
        }
        // Notify ad services that ad-free status has changed
        _notifyAdFreeStatusListeners();
        // Force UI refresh after successful restoration
        notifyListeners();
      } else {
        _errorMessage = 'No previous purchases found to restore';
        _purchaseErrorInfo = _classifyError(
          'No previous purchases found',
          isRestore: true,
        );
      }

      return success;
    } catch (e) {
      _errorMessage = 'Restore error: $e';
      _purchaseErrorInfo = _classifyError(e, isRestore: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    if (!_isInitialized) {
      _errorMessage = 'Purchase service not initialized';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _purchaseService.cancelSubscription();

      if (success) {
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to cancel subscription';
      }

      return success;
    } catch (e) {
      _errorMessage = 'Cancel subscription error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    _purchaseErrorInfo = null;
    notifyListeners();
  }

  /// Refresh subscription status
  void refreshStatus() {
    notifyListeners();
  }

  /// Add listener for ad-free status changes
  void addAdFreeStatusListener(VoidCallback listener) {
    _adFreeStatusListeners.add(listener);
  }

  /// Remove listener for ad-free status changes
  void removeAdFreeStatusListener(VoidCallback listener) {
    _adFreeStatusListeners.remove(listener);
  }

  /// Notify all ad-free status listeners
  void _notifyAdFreeStatusListeners() {
    for (final listener in _adFreeStatusListeners) {
      try {
        listener();
      } catch (e) {
        // Handle listener errors silently
      }
    }
  }

  @override
  void dispose() {
    _adFreeStatusListeners.clear();
    _purchaseService.dispose();
    super.dispose();
  }
}
