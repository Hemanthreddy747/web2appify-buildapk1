import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      // If no connectivity, return false
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      // Additional check: try to ping a reliable server
      return await _performNetworkCheck();
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Perform actual network check by pinging Google DNS
  static Future<bool> _performNetworkCheck() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      print('Network check error: $e');
      return false;
    }
  }

  /// Listen to connectivity changes
  static Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  /// Get current connectivity status
  static Future<List<ConnectivityResult>> getCurrentConnectivity() =>
      _connectivity.checkConnectivity();

  /// Check if connected to WiFi
  static Future<bool> isConnectedToWiFi() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  /// Check if connected to mobile data
  static Future<bool> isConnectedToMobile() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile);
  }
}
