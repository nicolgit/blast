import 'dart:io';
import 'dart:ui';
import 'package:blastapp/specific/desktopwindow/desktopwindow.dart';
import 'package:window_manager/window_manager.dart';

class BlastDesktopWindowMobile extends BlastDesktopWindow {
  @override
  void setMinWindowSize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.setMinimumSize(const Size(350, 350));
    }
  }
}

BlastDesktopWindow getBlastDesktopWindow() => BlastDesktopWindowMobile();
