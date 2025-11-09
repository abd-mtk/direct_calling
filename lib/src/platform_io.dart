// Platform detection for non-web platforms
import 'dart:io' as io;

bool get isAndroid => io.Platform.isAndroid;
bool get isIOS => io.Platform.isIOS;

