import 'package:blastapp/ViewModel/app_view_model.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastapp/blast_theme.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'win32register/win32register_stub.dart'
    if (dart.library.html) 'package:blastapp/win32register/win32register_web.dart'
    if (dart.library.io) 'package:blastapp/win32register/win32register_mobile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var r = getWin32Register();
  await r.register('blastapp'); // register custom protocol for windows client only

  /*
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SplashViewModel(context)),
        ChangeNotifierProvider(create: (context) => EulaViewModel(context)),
      ],
      child: BlastApp(),
    ),
  );
  */

  AppViewModel appViewModel = AppViewModel();
  runApp(BlastApp(await appViewModel.getAppTheme()));
}

class BlastApp extends StatefulWidget {
  final ThemeMode themeMode;
  const BlastApp(this.themeMode, {super.key});

  @override
  State<BlastApp> createState() => _BlastAppState(themeMode);
}

class _BlastAppState extends State<BlastApp> {
  final ThemeMode _themeMode;
  _BlastAppState(this._themeMode);

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
        useDefaultLoading: false,
        overlayWidgetBuilder: (_) {
          return const Center(child: CircularProgressIndicator());
        },
        overlayColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.8),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Blastapp title",
          home: MaterialApp.router(
            routerConfig: _appRouter.config(),
            theme: BlastTheme.dark,
            darkTheme: BlastTheme.dark,
            themeMode: _themeMode,
            /*  ThemeMode.system to follow system theme, 
                  ThemeMode.light for light theme, 
                  ThemeMode.dark for dark theme
              */
          ),
        ));
  }

  final _appRouter = BlastRouter();
}
