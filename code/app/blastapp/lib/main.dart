import 'dart:io' as io;
import 'package:blastapp/ViewModel/app_view_model.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastapp/blast_theme.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:desktop_window/desktop_window.dart';

import 'win32register/win32register_stub.dart'
    if (dart.library.html) 'package:blastapp/win32register/win32register_web.dart'
    if (dart.library.io) 'package:blastapp/win32register/win32register_mobile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var r = getWin32Register();
  await r
      .register('blastapp'); // register custom protocol for windows client only

  await DesktopWindow.setMinWindowSize(const Size(300, 300));

  AppViewModel appViewModel = AppViewModel();


  runApp(BlastApp(await appViewModel.getAppTheme()));
}

class BlastApp extends StatefulWidget {
  final ThemeMode themeMode;
  const BlastApp(this.themeMode, {super.key});

  @override
  State<BlastApp> createState() => BlastAppState(themeMode);

  static BlastAppState of(BuildContext context) =>
      context.findAncestorStateOfType<BlastAppState>()!;
}

class BlastAppState extends State<BlastApp> {
  ThemeMode _themeMode;
  BlastAppState(this._themeMode);

  late BlastWidgetFactory _widgetFactory;

  @override
  Widget build(BuildContext context) {
    _widgetFactory = BlastWidgetFactory(context);

    return GlobalLoaderOverlay(
        overlayWidgetBuilder: (_) {
          return const Center(child: CircularProgressIndicator());
        },
        overlayColor: _widgetFactory.theme.colorScheme.primary.withOpacity(0.8),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Blastapp title",
          home: MaterialApp.router(
            routerConfig: _appRouter.config(),
            theme: BlastTheme.light,
            darkTheme: BlastTheme.dark,
            themeMode: _themeMode,
            /*  ThemeMode.system to follow system theme, 
                  ThemeMode.light for light theme, 
                  ThemeMode.dark for dark theme
              */
          ),
        ));
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      FlutterWindowClose.setWebReturnValue(
          'File could not saved, are you sure?');
      return;
    } else {
      if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
        FlutterWindowClose.setWindowShouldCloseHandler(() async {
          final CurrentFileService currentFileService = CurrentFileService();

          if (currentFileService.currentFileDocument != null) {
            if (currentFileService.currentFileDocument!.isChanged) {
              final result = await FlutterPlatformAlert.showCustomAlert(
                windowTitle: "** You have unsaved data **",
                text: "Do you really want to quit?",
                positiveButtonTitle: "Yes, quit",
                negativeButtonTitle: "Cancel",
              );
              return result == CustomButton.positiveButton;
            }
          }

          return true;
        });
      }
    }
  }

  final _appRouter = BlastRouter();
}
