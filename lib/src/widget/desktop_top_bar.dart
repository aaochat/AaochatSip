import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../Providers/theme_provider.dart';
import '../utils/app_branding.dart';
import 'branded_logo.dart';

/// Desktop window header — title, section, and primary actions (not mobile AppBar).
class DesktopTopBar extends StatelessWidget {
  const DesktopTopBar({
    super.key,
    required this.sectionTitle,
    this.subtitle,
    this.actions = const [],
    this.showWindowControls = true,
  });

  final String sectionTitle;
  final String? subtitle;
  final List<Widget> actions;
  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ThemeProvider.cardDark,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          if (Platform.isWindows) ...[
            const DragToMoveArea(
              child: SizedBox(
                width: 140,
                child: Row(
                  children: [
                    BrandedLogo(height: 28),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AppBranding.appName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          Expanded(
            child: Platform.isWindows
                ? DragToMoveArea(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _TitleBlock(title: sectionTitle, subtitle: subtitle),
                    ),
                  )
                : _TitleBlock(title: sectionTitle, subtitle: subtitle),
          ),
          ...actions,
          if (showWindowControls && Platform.isWindows) ...[
            IconButton(
              tooltip: 'Minimize',
              onPressed: () => windowManager.minimize(),
              icon: const Icon(Icons.remove, size: 18),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: () => windowManager.close(),
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        if (subtitle != null)
          Text(subtitle!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
