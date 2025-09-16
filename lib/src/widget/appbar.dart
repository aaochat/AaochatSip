import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class ThemeAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return Platform.isWindows || Platform.isMacOS ? PreferredSize(
          preferredSize: const Size(double.maxFinite, 50),
          child: DragToMoveArea(
            child: AppBar(
              backgroundColor: Colors.grey.shade900,
              leading: Padding(padding: EdgeInsets.all(10),child: Image.asset('assets/voip_logo.png',)),
              title: Text("Aao VOIP",style: TextStyle(color: Colors.white, fontSize: 20),),
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
        ): AppBar(
               leading: Padding(padding: EdgeInsets.all(10),child: Image.asset('assets/voip_logo.png',)),
               title: Text('Aao VOIP', style: TextStyle(fontSize: 20),), actions: [SizedBox(width: 10)]);
  }
}