import 'package:blastapp/ViewModel/app_view_model.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastapp/blast_theme.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'win32register/win32register_stub.dart'
    if (dart.library.html) 'package:blastapp/win32register/win32register_web.dart'
    if (dart.library.io) 'package:blastapp/win32register/win32register_mobile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var r = getWin32Register();
  await r.register('blastapp'); // register custom protocol for windows client only

  AppViewModel appViewModel = AppViewModel();
  runApp(BlastApp(await appViewModel.getAppTheme()));
}

class BlastApp extends StatefulWidget {
  final ThemeMode themeMode;
  const BlastApp(this.themeMode, {super.key});

  @override
  State<BlastApp> createState() => BlastAppState(themeMode);

  static BlastAppState of(BuildContext context) => context.findAncestorStateOfType<BlastAppState>()!;
}

class BlastAppState extends State<BlastApp> {
  ThemeMode _themeMode;
  BlastAppState(this._themeMode);

  late BlastWidgetFactory _widgetFactory;

  @override
  Widget build(BuildContext context) {
    _widgetFactory = BlastWidgetFactory(context);

    return GlobalLoaderOverlay(
        useDefaultLoading: false,
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

  final _appRouter = BlastRouter();
}
