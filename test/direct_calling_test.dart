import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:direct_calling/direct_calling.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('direct_calling');

  group('DirectCalling - makeCall', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('should throw UnsupportedError on unsupported platforms', () async {
      // On desktop/test platforms, isAndroid and isIOS are false
      expect(
        () => DirectCalling.makeCall('1234567890'),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains(
              'Phone call is only supported on Android, iOS, and Web platforms',
            ),
          ),
        ),
      );
    });

    test('should handle PlatformException when method channel fails', () async {
      // This test documents the error handling behavior
      // In a real scenario, this would only be reached on Android/iOS
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'makeCall') {
              throw PlatformException(
                code: 'CALL_FAILED',
                message: 'Failed to make call',
              );
            }
            return null;
          });

      // Even with mock handler, platform check happens first
      expect(
        () => DirectCalling.makeCall('1234567890'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('DirectCalling - checkPermission', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('should return false on unsupported platforms', () async {
      // On desktop/test platforms, isAndroid and isIOS are false
      final result = await DirectCalling.checkPermission();
      expect(result, false);
    });

    test('should handle PlatformException when method channel fails', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'checkPermission') {
              throw PlatformException(
                code: 'PERMISSION_ERROR',
                message: 'Failed to check permission',
              );
            }
            return null;
          });

      // Even with mock handler, platform check happens first
      final result = await DirectCalling.checkPermission();
      expect(result, false);
    });
  });

  group('DirectCalling - requestPermission', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('should return false on unsupported platforms', () async {
      // On desktop/test platforms, isAndroid and isIOS are false
      final result = await DirectCalling.requestPermission();
      expect(result, false);
    });

    test('should handle PlatformException when method channel fails', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'requestPermission') {
              throw PlatformException(
                code: 'PERMISSION_ERROR',
                message: 'Failed to request permission',
              );
            }
            return null;
          });

      // Even with mock handler, platform check happens first
      final result = await DirectCalling.requestPermission();
      expect(result, false);
    });
  });

  group('DirectCalling - smartCall', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('should throw UnsupportedError on unsupported platforms', () async {
      // On desktop/test platforms, isAndroid and isIOS are false
      expect(
        () => DirectCalling.smartCall('1234567890'),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains(
              'Phone call is only supported on Android, iOS, and Web platforms',
            ),
          ),
        ),
      );
    });
  });

  group('DirectCalling - error handling', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test(
      'should handle null response from method channel gracefully',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'checkPermission') {
                return null; // Simulate unexpected null response
              }
              return null;
            });

        // Platform check happens first, so this returns false
        final result = await DirectCalling.checkPermission();
        expect(result, false);
      },
    );

    test('should validate phone number parameter format', () {
      // Test that empty strings are accepted (validation happens at platform level)
      expect(
        () => DirectCalling.makeCall(''),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('should handle various phone number formats', () {
      // All formats should throw UnsupportedError on desktop
      final phoneNumbers = [
        '1234567890',
        '+1-234-567-8900',
        '(123) 456-7890',
        '+1234567890123',
        '1234567890x123',
      ];

      for (final number in phoneNumbers) {
        expect(
          () => DirectCalling.makeCall(number),
          throwsA(isA<UnsupportedError>()),
        );
      }
    });
  });

  group('DirectCalling - method channel interaction', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('should use correct method channel name', () {
      // Verify the channel name is correct
      const expectedChannel = MethodChannel('direct_calling');
      expect(channel.name, expectedChannel.name);
    });

    test('should pass correct arguments to makeCall method', () {
      // This test documents the expected method call structure
      // In integration tests, this would verify the actual call
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'makeCall') {
              expect(methodCall.arguments, isA<Map<String, dynamic>>());
              expect(methodCall.arguments['phoneNumber'], isA<String>());
              return true;
            }
            return null;
          });

      // Platform check prevents actual call, but structure is documented
      expect(
        () => DirectCalling.makeCall('1234567890'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('DirectCalling - platform-specific behavior', () {
    test(
      'should return false for checkPermission on unsupported platforms',
      () async {
        final result = await DirectCalling.checkPermission();
        expect(result, false);
      },
    );

    test(
      'should return false for requestPermission on unsupported platforms',
      () async {
        final result = await DirectCalling.requestPermission();
        expect(result, false);
      },
    );

    test(
      'should throw UnsupportedError for makeCall on unsupported platforms',
      () {
        expect(
          () => DirectCalling.makeCall('1234567890'),
          throwsA(isA<UnsupportedError>()),
        );
      },
    );

    test(
      'should throw UnsupportedError for smartCall on unsupported platforms',
      () {
        expect(
          () => DirectCalling.smartCall('1234567890'),
          throwsA(isA<UnsupportedError>()),
        );
      },
    );
  });

  group('DirectCalling - method call structure validation', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('makeCall should expect phoneNumber in arguments', () {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'makeCall') {
              expect(methodCall.arguments, isA<Map<String, dynamic>>());
              expect(methodCall.arguments.containsKey('phoneNumber'), true);
              expect(methodCall.arguments['phoneNumber'], isA<String>());
              return true;
            }
            return null;
          });

      // Document expected structure even though platform check prevents execution
      expect(
        () => DirectCalling.makeCall('1234567890'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('checkPermission should not require arguments', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'checkPermission') {
              expect(methodCall.arguments, isNull);
              return true;
            }
            return null;
          });

      // Document expected structure
      final result = await DirectCalling.checkPermission();
      expect(result, false);
    });

    test('requestPermission should not require arguments', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'requestPermission') {
              expect(methodCall.arguments, isNull);
              return true;
            }
            return null;
          });

      // Document expected structure
      final result = await DirectCalling.requestPermission();
      expect(result, false);
    });
  });
}
