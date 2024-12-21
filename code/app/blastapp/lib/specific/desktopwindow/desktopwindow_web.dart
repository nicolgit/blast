import 'package:blastapp/specific/desktopwindow/desktopwindow.dart';

class BlastDesktopWindowWeb implements BlastDesktopWindow {
  @override
  void setMinWindowSize() {
    // nothing to do on web
  }
}

BlastDesktopWindow getBlastDesktopWindow() => BlastDesktopWindowWeb();
