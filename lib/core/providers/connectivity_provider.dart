import 'package:flutter/foundation.dart';
import '../services/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isConnected = true;
  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get showNoInternetScreen => !_isConnected && _isInitialized;

  ConnectivityProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _connectivityService.initialize();
      _isConnected = _connectivityService.isConnected;

      // Listen to connectivity changes
      _connectivityService.connectionStatusStream.listen((isConnected) {
        _isConnected = isConnected;
        notifyListeners();
      });

      _isInitialized = true;
    } catch (e) {
      // Assume connected if we can't initialize
      _isConnected = true;
      _isInitialized = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Manually check connectivity
  Future<bool> checkConnectivity() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isConnected = await _connectivityService.checkConnectivity();
    } catch (e) {
      _isConnected = false;
    }

    _isLoading = false;
    notifyListeners();
    return _isConnected;
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
