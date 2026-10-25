import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _isConnected = _testOfflineMode ? false : true;
  bool get isConnected => _isConnected;

  // Test için geçici flag
  static bool _testOfflineMode = false;
  static void setTestOfflineMode(bool offline) {
    _testOfflineMode = offline;
  }

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity status
      final result = await _connectivity.checkConnectivity();
      _isConnected = result != ConnectivityResult.none;

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        ConnectivityResult result,
      ) {
        final wasConnected = _isConnected;
        _isConnected = result != ConnectivityResult.none;

        // Notify listeners if connection status changed
        if (wasConnected != _isConnected) {
          _connectionStatusController.add(_isConnected);
        }
      });
    } catch (e) {
      // Assume connected if we can't check
      _isConnected = true;
    }
  }

  /// Stream controller for connection status changes
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// Check if currently connected
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = result != ConnectivityResult.none;
      return _isConnected;
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}
