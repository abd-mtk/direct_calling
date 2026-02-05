# direct_calling

A Flutter plugin for making direct phone calls on Android and Web. This plugin provides a simple and unified API to initiate phone calls with proper permission handling.

## Features

- 📱 **Android & Web**: Works on Android and Web
- 🔐 **Smart permission handling**: Automatically checks and requests permissions on Android
- 🎯 **Simple API**: Easy-to-use methods for making phone calls
- ⚡ **Direct calls**: Makes direct calls on Android (with permission)
- 🌐 **Web support**: Uses tel: links for web browsers
- 📵 **iOS**: Not supported; methods return `false` without doing anything (no crash)

## Platform Support

| Platform | Support | Behavior                                                   |
| -------- | ------- | ---------------------------------------------------------- |
| Android  | ✅      | Makes direct phone call (requires `CALL_PHONE` permission) |
| Web      | ✅      | Opens tel: link (browser-dependent)                       |
| iOS      | ❌      | No-op; returns `false` (calling not supported)             |
| Other    | ❌      | Throws `UnsupportedError`                                  |

## Installation

Add `direct_calling` to your `pubspec.yaml` file:

```yaml
dependencies:
  direct_calling: ^1.1.0
```

Then run:

```bash
flutter pub get
```

## Setup

### Android

Add the `CALL_PHONE` permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.CALL_PHONE" />
    <!-- ... other permissions ... -->
</manifest>
```

**Note**: The permission is already included in the plugin's AndroidManifest, but you may need to add it to your app's manifest as well depending on your setup.

### iOS

Not supported. On iOS, all methods return `false` without performing any action (no native code, no Podfile required).

### Web

No additional setup required. The plugin uses standard `tel:` links.

## Usage

### Basic Example

```dart
import 'package:direct_calling/direct_calling.dart';

// Make a phone call
try {
  bool success = await DirectCalling.makeCall('1234567890');
  if (success) {
    print('Call initiated successfully');
  }
} catch (e) {
  print('Failed to make call: $e');
}
```

### Smart Call (Recommended)

The `smartCall` method automatically handles permissions:

```dart
import 'package:direct_calling/direct_calling.dart';

// Smart call - handles permissions automatically
try {
  bool success = await DirectCalling.smartCall('+1234567890');
  if (success) {
    print('Call initiated successfully');
  }
} catch (e) {
  print('Failed to make call: $e');
}
```

### Manual Permission Handling

If you need more control over permissions:

```dart
import 'package:direct_calling/direct_calling.dart';

// Check permission status
bool hasPermission = await DirectCalling.checkPermission();
if (!hasPermission) {
  // Request permission
  bool granted = await DirectCalling.requestPermission();
  if (granted) {
    // Make the call
    await DirectCalling.makeCall('1234567890');
  } else {
    print('Permission denied');
  }
} else {
  // Permission already granted, make the call
  await DirectCalling.makeCall('1234567890');
}
```

### Complete Example

```dart
import 'package:direct_calling/direct_calling.dart';
import 'package:flutter/material.dart';

class CallButton extends StatelessWidget {
  final String phoneNumber;

  const CallButton({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.phone),
      label: const Text('Call'),
      onPressed: () async {
        try {
          bool success = await DirectCalling.smartCall(phoneNumber);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calling...')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to make call: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}
```

## API Reference

### `DirectCalling.makeCall(String phoneNumber)`

Makes a phone call to the specified phone number.

**Parameters:**

- `phoneNumber` (String): The phone number to call (can include formatting like `+1-234-567-8900`)

**Returns:**

- `Future<bool>`: `true` if the call was initiated successfully, `false` otherwise

**Throws:**

- `UnsupportedError`: If the platform is not supported
- `Exception`: If the call fails

**Platform behavior:**

- **Android**: Makes a direct call (requires `CALL_PHONE` permission)
- **Web**: Opens a tel: link
- **iOS**: Not supported; returns `false`

---

### `DirectCalling.checkPermission()`

Checks if the device can make phone calls.

**Returns:**

- `Future<bool>`: `true` if permission is granted/available, `false` otherwise

**Platform behavior:**

- **Android**: Checks if `CALL_PHONE` permission is granted
- **Web**: Always returns `true`
- **iOS**: Not supported; returns `false`
- **Other**: Returns `false`

---

### `DirectCalling.requestPermission()`

Requests permission to make phone calls.

**Returns:**

- `Future<bool>`: `true` if permission was granted, `false` if denied

**Platform behavior:**

- **Android**: Shows permission dialog for `CALL_PHONE` permission
- **Web**: Returns `true` (no permission needed for tel: URLs)
- **iOS**: Not supported; returns `false`
- **Other**: Returns `false`

---

### `DirectCalling.smartCall(String phoneNumber)`

Smart call method that automatically handles permissions before making a call.

**Parameters:**

- `phoneNumber` (String): The phone number to call

**Returns:**

- `Future<bool>`: `true` if the call was initiated successfully

**Throws:**

- `UnsupportedError`: If the platform is not supported
- `Exception`: If permission is denied or call fails

**Platform behavior:**

- **Android**: Checks permission → requests if needed → makes direct call
- **Web**: Directly makes the call (no permission needed)
- **iOS**: Not supported; returns `false`

## Phone Number Formats

The plugin accepts various phone number formats:

```dart
// All of these work:
await DirectCalling.makeCall('1234567890');
await DirectCalling.makeCall('+1-234-567-8900');
await DirectCalling.makeCall('(123) 456-7890');
await DirectCalling.makeCall('+1234567890123');
await DirectCalling.makeCall('1234567890x123'); // With extension
```

## Error Handling

Always wrap calls in try-catch blocks:

```dart
try {
  await DirectCalling.smartCall('1234567890');
} on UnsupportedError catch (e) {
  // Platform not supported
  print('Platform not supported: $e');
} on Exception catch (e) {
  // Other errors (permission denied, call failed, etc.)
  print('Error: $e');
}
```

## Platform-Specific Notes

### Android

- Requires `CALL_PHONE` permission in AndroidManifest.xml
- Permission is requested at runtime (Android 6.0+)
- Makes direct calls without user interaction (if permission granted)
- If permission is denied, the call will fail

### iOS

- **Not supported.** All methods return `false` without performing any action.
- No native iOS code or CocoaPods setup is required.

### Web

- Uses standard `tel:` links
- Behavior depends on browser and device capabilities
- On desktop, may open a calling app if available
- On mobile web, typically opens the device's calling interface

## Requirements

- Flutter SDK: `>=3.0.0`
- Dart SDK: `>=3.7.0 <4.0.0`
- Android: Minimum SDK 24
- iOS: Not supported (methods return `false`)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the terms specified in the LICENSE file.

## Support

For issues, feature requests, or questions, please open an issue on the project repository.

---

**Made with ❤️ for Flutter developers**
