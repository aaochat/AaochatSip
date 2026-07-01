import 'dart:io';
import 'dart:ui';

import 'package:aaochat_sip/src/utils/app_branding.dart';
import 'package:aaochat_sip/src/widget/branded_logo.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class ThemeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ThemeAppBar({super.key, this.title});

  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? AppBranding.appName;
    if (Platform.isWindows) {
      return PreferredSize(
        preferredSize: const Size(double.maxFinite, 50),
        child: DragToMoveArea(
          child: AppBar(
            leading: const Padding(
              padding: EdgeInsets.all(10),
              child: BrandedLogo(),
            ),
            title: Text(displayTitle, style: const TextStyle(color: Colors.white, fontSize: 20)),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => windowManager.minimize(),
                icon: const Icon(Icons.minimize),
              ),
              IconButton(
                onPressed: () => windowManager.close(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      );
    }
    return AppBar(
      leading: const Padding(padding: EdgeInsets.all(10), child: BrandedLogo()),
      title: Text(displayTitle, style: const TextStyle(fontSize: 20)),
      actions: const [SizedBox(width: 10)],
    );
  }
}
