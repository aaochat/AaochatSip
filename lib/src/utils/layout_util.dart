import 'dart:io';

class LayoutUtil {
  static bool isMobile() => Platform.isAndroid || Platform.isIOS;

  /// Windows, macOS, and Linux (windowed targets).
  static bool isDesktop() => !isMobile();
}
