import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

// Conditional imports for platform detection
import 'src/platform_stub.dart' if (dart.library.io) 'src/platform_io.dart';

// Conditional imports for web implementation
import 'src/direct_calling_stub.dart'
    if (dart.library.html) 'src/direct_calling_web.dart';

class DirectCalling {
  static const MethodChannel _channel = MethodChannel('direct_calling');

  /// Makes a phone call to the specified phone number
  /// - Android: Makes a direct call (requires CALL_PHONE permission)
  /// - Web: Opens tel: link (browser-dependent)
  /// - iOS: Not supported; returns false without doing anything
  static Future<bool> makeCall(String phoneNumber) async {
    if (kIsWeb) {
      try {
        return makeCallWeb(phoneNumber);
      } catch (e) {
        throw Exception('Failed to make call on web: $e');
      }
    }

    // iOS: calling not supported; do nothing
    if (isIOS) return false;

    if (!isAndroid) {
      throw UnsupportedError(
        'Phone call is only supported on Android and Web platforms',
      );
    }

    try {
      final bool result = await _channel.invokeMethod('makeCall', {
        'phoneNumber': phoneNumber,
      });
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to make call: ${e.message}');
    }
  }

  /// Checks if the device can make phone calls
  /// - Android: Checks if CALL_PHONE permission is granted
  /// - Web: Returns true (tel: links are supported in browsers)
  /// - iOS: Not supported; returns false
  static Future<bool> checkPermission() async {
    if (kIsWeb) return true;
    if (isIOS) return false;

    if (!isAndroid) return false;

    try {
      final bool result = await _channel.invokeMethod('checkPermission');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to check permission: ${e.message}');
    }
  }

  /// Requests permission to make phone calls
  /// - Android: Requests CALL_PHONE permission
  /// - Web: Returns true (no permission needed for tel: URLs)
  /// - iOS: Not supported; returns false
  static Future<bool> requestPermission() async {
    if (kIsWeb) return true;
    if (isIOS) return false;

    if (!isAndroid) return false;

    try {
      final bool result = await _channel.invokeMethod('requestPermission');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to request permission: ${e.message}');
    }
  }

  /// Smart call method that checks permission and makes call
  /// - Android: Checks/requests CALL_PHONE permission, then makes direct call
  /// - Web: Opens tel: link (browser-dependent)
  /// - iOS: Not supported; returns false without doing anything
  static Future<bool> smartCall(String phoneNumber) async {
    if (kIsWeb) return await makeCall(phoneNumber);
    if (isIOS) return false;

    if (!isAndroid) {
      throw UnsupportedError(
        'Phone call is only supported on Android and Web platforms',
      );
    }

    bool hasPermission = await checkPermission();
    if (!hasPermission) {
      hasPermission = await requestPermission();
      if (!hasPermission) {
        throw Exception('Call permission was denied');
      }
    }
    return await makeCall(phoneNumber);
  }
}
