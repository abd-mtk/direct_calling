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
  /// - iOS: Opens the Phone app with the number pre-filled
  /// - Web: Opens tel: link (browser-dependent)
  static Future<bool> makeCall(String phoneNumber) async {
    if (kIsWeb) {
      // Web implementation
      try {
        return makeCallWeb(phoneNumber);
      } catch (e) {
        throw Exception('Failed to make call on web: $e');
      }
    }

    if (!isAndroid && !isIOS) {
      throw UnsupportedError(
        'Phone call is only supported on Android, iOS, and Web platforms',
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
  /// - iOS: Checks if device can make phone calls (no permission needed)
  /// - Web: Returns true (tel: links are supported in browsers)
  static Future<bool> checkPermission() async {
    if (kIsWeb) {
      // On web, tel: links are generally supported
      return true;
    }

    if (!isAndroid && !isIOS) {
      return false;
    }

    try {
      final bool result = await _channel.invokeMethod('checkPermission');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to check permission: ${e.message}');
    }
  }

  /// Requests permission to make phone calls
  /// - Android: Requests CALL_PHONE permission
  /// - iOS: Returns true (no permission needed for tel: URLs)
  /// - Web: Returns true (no permission needed for tel: URLs)
  static Future<bool> requestPermission() async {
    if (kIsWeb) {
      // On web, tel: links don't require permissions
      return true;
    }

    if (!isAndroid && !isIOS) {
      return false;
    }

    try {
      final bool result = await _channel.invokeMethod('requestPermission');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to request permission: ${e.message}');
    }
  }

  /// Smart call method that checks permission and makes call
  /// - Android: Checks/requests CALL_PHONE permission, then makes direct call
  /// - iOS: Opens Phone app with number pre-filled (no permission needed)
  /// - Web: Opens tel: link (browser-dependent)
  static Future<bool> smartCall(String phoneNumber) async {
    if (kIsWeb) {
      // On web, directly make the call (no permission needed)
      return await makeCall(phoneNumber);
    }

    if (!isAndroid && !isIOS) {
      throw UnsupportedError(
        'Phone call is only supported on Android, iOS, and Web platforms',
      );
    }

    // On iOS, no permission is needed, so we can directly make the call
    if (isIOS) {
      return await makeCall(phoneNumber);
    }

    // On Android, check if permission is already granted
    bool hasPermission = await checkPermission();

    if (!hasPermission) {
      // Request permission
      hasPermission = await requestPermission();

      if (!hasPermission) {
        throw Exception('Call permission was denied');
      }
    }

    // Make the call
    return await makeCall(phoneNumber);
  }
}
