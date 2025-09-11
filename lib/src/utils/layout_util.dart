import 'dart:io';


class LayoutUtil {
  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }
}