// ignore_for_file: unused_local_variable, empty_catches

import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InAppPurchaseService {
  static final InAppPurchaseService _instance =
      InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  // Platform-specific product IDs
  static const String _adFreeSubscriptionIdIOS = 'remove_ads_one_time';
  static const String _adFreeSubscriptionIdAndroid = 'one_time_payment';

  // Get the appropriate product ID based on platform
  String get _adFreeSubscriptionId {
    if (Platform.isIOS) {
      return _adFreeSubscriptionIdIOS;
    } else if (Platform.isAndroid) {
      return _adFreeSubscriptionIdAndroid;
    } else {
      // Default to iOS ID for other platforms
      return _adFreeSubscriptionIdIOS;
    }
  }

  static const String _isAdFreeKey = 'is_ad_free';
  static const String _subscriptionExpiryKey = 'subscription_expiry';
  static const String _subscriptionStartKey = 'subscription_start';
  static const String _lastPaymentDateKey = 'last_payment_date';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAdFree = false;
  DateTime? _subscriptionExpiry;
  DateTime? _subscriptionStart;
  DateTime? _lastPaymentDate;
  bool _isInitialized = false;
  bool _isAvailable = false;
  String? _lastPurchaseError;
  String? _lastPurchaseErrorCode;

  bool get isAdFree => _isAdFree;
  DateTime? get subscriptionExpiry => _subscriptionExpiry;
  DateTime? get subscriptionStart => _subscriptionStart;
  DateTime? get lastPaymentDate => _lastPaymentDate;
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isAvailable;
  String? get lastPurchaseError => _lastPurchaseError;
  String? get lastPurchaseErrorCode => _lastPurchaseErrorCode;

  /// Get the current platform's product ID (for debugging/logging)
  String get currentProductId => _adFreeSubscriptionId;

  /// Initialize the in-app purchase service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check if in-app purchase is available
      _isAvailable = await _inAppPurchase.isAvailable();

      if (!_isAvailable) {
        throw Exception('In-app purchase not available on this device');
      }

      // Load saved subscription status
      await _loadSubscriptionStatus();

      // For iOS, ensure ad-free status is properly loaded
      if (Platform.isIOS && _isAdFree) {
        // Double-check that the ad-free status is correctly loaded
        final prefs = await SharedPreferences.getInstance();
        final savedAdFreeStatus = prefs.getBool(_isAdFreeKey) ?? false;
        if (savedAdFreeStatus != _isAdFree) {
          _isAdFree = savedAdFreeStatus;
        }
      }

      // For iOS, we'll rely on the purchase stream and restore mechanism
      // The purchase history verification will be handled during restore

      // Listen to purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          // Handle error silently in production
        },
      );

      _isInitialized = true;
    } catch (e) {
      // Handle error silently in production
    }
  }

  // /// Ensure local ad-free flag reflects store ownership (Android)
  // Future<void> _syncOwnedPurchaseFromStore() async {
  //   try {
  //     // Only attempt when store is available and not on iOS
  //     if (!_isAvailable || Platform.isIOS) return;

  //     final response = await _inAppPurchase.queryPurchaseHistory();
  //     if (response.error != null) {
  //       return;
  //     }

  //     final owned = response.pastPurchases.any((p) =>
  //         p.productID == _adFreeSubscriptionIdAndroid ||
  //         p.productID == _adFreeSubscriptionIdIOS);

  //     if (owned && !_isAdFree) {
  //       _isAdFree = true;
  //       _subscriptionExpiry = null;
  //       _subscriptionStart ??= DateTime.now();
  //       _lastPaymentDate ??= DateTime.now();
  //       await _saveSubscriptionStatus();
  //     }
  //   } catch (_) {
  //     // Silently ignore if not supported
  //   }
  // }

  /// Load subscription status from SharedPreferences
  Future<void> _loadSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAdFree = prefs.getBool(_isAdFreeKey) ?? false;

      final expiryTimestamp = prefs.getInt(_subscriptionExpiryKey);
      if (expiryTimestamp != null) {
        _subscriptionExpiry = DateTime.fromMillisecondsSinceEpoch(
          expiryTimestamp,
        );
      }

      final startTimestamp = prefs.getInt(_subscriptionStartKey);
      if (startTimestamp != null) {
        _subscriptionStart = DateTime.fromMillisecondsSinceEpoch(
          startTimestamp,
        );
      }

      final lastPaymentTimestamp = prefs.getInt(_lastPaymentDateKey);
      if (lastPaymentTimestamp != null) {
        _lastPaymentDate = DateTime.fromMillisecondsSinceEpoch(
          lastPaymentTimestamp,
        );
      }

      // Check if subscription has expired
      if (_isAdFree &&
          _subscriptionExpiry != null &&
          _subscriptionExpiry!.isBefore(DateTime.now())) {
        _isAdFree = false;
        await _saveSubscriptionStatus();
      }
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Save subscription status to SharedPreferences
  Future<void> _saveSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isAdFreeKey, _isAdFree);

      if (_subscriptionExpiry != null) {
        await prefs.setInt(
          _subscriptionExpiryKey,
          _subscriptionExpiry!.millisecondsSinceEpoch,
        );
      } else {
        await prefs.remove(_subscriptionExpiryKey);
      }

      if (_subscriptionStart != null) {
        await prefs.setInt(
          _subscriptionStartKey,
          _subscriptionStart!.millisecondsSinceEpoch,
        );
      } else {
        await prefs.remove(_subscriptionStartKey);
      }

      if (_lastPaymentDate != null) {
        await prefs.setInt(
          _lastPaymentDateKey,
          _lastPaymentDate!.millisecondsSinceEpoch,
        );
      } else {
        await prefs.remove(_lastPaymentDateKey);
      }
    } catch (e) {
      // Handle error silently in production
    }
  }

  /// Save subscription status with retry mechanism for iOS
  Future<void> _saveSubscriptionStatusWithRetry() async {
    const maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _saveSubscriptionStatus();

        // Verify the save was successful by reading it back
        final prefs = await SharedPreferences.getInstance();
        final savedAdFreeStatus = prefs.getBool(_isAdFreeKey) ?? false;

        if (savedAdFreeStatus == _isAdFree) {
          // Save was successful
          return;
        } else if (attempt < maxRetries) {
          // Save failed, wait and retry
          await Future.delayed(Duration(milliseconds: 100 * attempt));
        }
      } catch (e) {
        if (attempt < maxRetries) {
          // Wait before retry
          await Future.delayed(Duration(milliseconds: 100 * attempt));
        }
      }
    }
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending purchase
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Handle successful purchase
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle purchase error with detailed information
        final errorMessage =
            purchaseDetails.error?.message ?? 'Unknown purchase error';
        final errorCode = purchaseDetails.error?.code ?? 'unknown';
        print('Purchase error: $errorMessage (Code: $errorCode)');

        // Store the detailed error for the provider to use
        _lastPurchaseError = errorMessage;
        _lastPurchaseErrorCode = errorCode;
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        // Handle canceled purchase
        print('Purchase canceled by user');
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Handle successful purchase
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    // Check for both iOS and Android product IDs
    if (purchaseDetails.productID == _adFreeSubscriptionIdIOS ||
        purchaseDetails.productID == _adFreeSubscriptionIdAndroid) {
      // Additional validation for iOS
      if (Platform.isIOS) {
        // Verify the purchase is not null and has valid transaction data
        if (purchaseDetails.purchaseID == null ||
            purchaseDetails.purchaseID!.isEmpty) {
          return; // Invalid purchase
        }
      }

      final now = DateTime.now();

      _isAdFree = true;
      _lastPaymentDate = now;
      _subscriptionStart = now;

      // For one-time payment, no expiry date (lifetime)
      _subscriptionExpiry = null;

      // Save subscription status with retry mechanism for iOS
      await _saveSubscriptionStatusWithRetry();
    }
  }

  /// Purchase ad-free subscription
  Future<bool> purchaseAdFreeSubscription() async {
    try {
      // Check if already subscribed
      if (_isAdFree) {
        return true;
      }

      // Verify in-app purchase is available
      if (!_isAvailable) {
        throw Exception('In-app purchase not available on this device');
      }

      // Get product details
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails({_adFreeSubscriptionId});

      if (response.error != null) {
        throw Exception('Product query failed: ${response.error!.message}');
      }

      if (response.productDetails.isEmpty) {
        throw Exception('Product not found: $_adFreeSubscriptionId');
      }

      // Validate product details
      final ProductDetails productDetails = response.productDetails.first;
      if (productDetails.id != _adFreeSubscriptionId) {
        throw Exception(
          'Product ID mismatch: expected $_adFreeSubscriptionId, got ${productDetails.id}',
        );
      }

      // Create purchase params
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      // Start purchase (one-time payment)
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (success) {
        return true;
      }

      // If purchase didn't complete (e.g., already owned), try restore as fallback
      final restored = await restorePurchases();
      return restored;
    } catch (e) {
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      // Check if already ad-free (no need to restore if already active)
      if (_isAdFree) {
        return true;
      }

      // Call the platform's restore purchases method
      await _inAppPurchase.restorePurchases();

      // The actual restoration will be handled by _onPurchaseUpdate
      // when the restored purchases come through the purchase stream

      // Wait a bit for the purchase stream to process the restored purchases
      await Future.delayed(const Duration(seconds: 2));

      // For iOS, the restore mechanism will trigger purchase stream updates
      // which will be handled by _onPurchaseUpdate method

      // For iOS, double-check the ad-free status after restore
      if (Platform.isIOS) {
        final prefs = await SharedPreferences.getInstance();
        final savedAdFreeStatus = prefs.getBool(_isAdFreeKey) ?? false;
        if (savedAdFreeStatus != _isAdFree) {
          _isAdFree = savedAdFreeStatus;
        }
      }

      // Check if restoration was successful by checking if we're now ad-free
      return _isAdFree;
    } catch (e) {
      // Handle error silently in production
      return false;
    }
  }

  /// Cancel subscription (clear ad-free status)
  Future<bool> cancelSubscription() async {
    try {
      // Clear ad-free status
      _isAdFree = false;
      _subscriptionExpiry = null;
      _subscriptionStart = null;
      _lastPaymentDate = null;

      // Save the updated status
      await _saveSubscriptionStatus();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if subscription is active (for lifetime access, always true if purchased)
  bool isSubscriptionActive() {
    // For iOS, double-check the ad-free status from storage
    if (Platform.isIOS) {
      _verifyAdFreeStatusFromStorage();
    }
    return _isAdFree;
  }

  /// Clear last purchase error
  void clearLastPurchaseError() {
    _lastPurchaseError = null;
    _lastPurchaseErrorCode = null;
  }

  /// Verify ad-free status from storage (iOS specific)
  void _verifyAdFreeStatusFromStorage() {
    try {
      SharedPreferences.getInstance().then((prefs) {
        final savedAdFreeStatus = prefs.getBool(_isAdFreeKey) ?? false;
        if (savedAdFreeStatus != _isAdFree) {
          _isAdFree = savedAdFreeStatus;
        }
      });
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get remaining subscription days (for lifetime access, returns -1)
  int getRemainingDays() {
    if (!_isAdFree) return 0;
    return -1; // -1 indicates lifetime access
  }

  /// Check if it's time for next payment (not applicable for lifetime access)
  bool get isPaymentDueSoon {
    return false; // No payment due for lifetime access
  }

  /// Get subscription duration in days
  int getSubscriptionDuration() {
    if (_subscriptionStart == null || _subscriptionExpiry == null) return 0;
    return _subscriptionExpiry!.difference(_subscriptionStart!).inDays;
  }

  /// Get subscription status text
  String getSubscriptionStatusText() {
    if (!_isAdFree) return 'Not purchased';
    return 'Lifetime access';
  }

  /// Debug method to check service status
  Future<Map<String, dynamic>> getDebugInfo() async {
    return {
      'isInitialized': _isInitialized,
      'isAvailable': _isAvailable,
      'isAdFree': _isAdFree,
      'currentProductId': _adFreeSubscriptionId,
      'platform': Platform.operatingSystem,
      'subscriptionExpiry': _subscriptionExpiry?.toIso8601String(),
      'subscriptionStart': _subscriptionStart?.toIso8601String(),
      'lastPaymentDate': _lastPaymentDate?.toIso8601String(),
    };
  }

  /// Test method for development
  Future<void> testConnection() async {
    try {
      if (!_isAvailable) {
        return;
      }

      if (!_isInitialized) {
        return;
      }

      // Test product query
      final response = await _inAppPurchase.queryProductDetails({
        _adFreeSubscriptionId,
      });

      if (response.error != null) {
      } else if (response.productDetails.isEmpty) {
      } else {
        for (final product in response.productDetails) {}
      }
    } catch (e) {}
  }

  /// Simple test method that can be called from UI
  Future<String> quickTest() async {
    try {
      await testConnection();
      return 'Test completed. Check console for details.';
    } catch (e) {
      return 'Test failed: $e';
    }
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
