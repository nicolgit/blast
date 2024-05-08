import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/splash_view_model.dart';
import 'package:blastapp/main.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/secrets.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SplashViewModel(context),
      child: Consumer<SplashViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late ThemeData _theme;
  late TextTheme _textTheme;

  Widget _buildScaffold(BuildContext context, SplashViewModel vm) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onBackground);

    return Scaffold(
        backgroundColor: _theme.colorScheme.background,
        body: Center(
            child: Column(
          children: [
            const Image(image: AssetImage('assets/general/icon-v01.png')),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(children: [
                Text(
                  "your passwords, safe and sound.",
                  style: _textTheme.labelLarge,
                ),
                Text(
                  "build ${Secrets.buildNumber}",
                  style: _textTheme.labelSmall,
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: FilledButton.tonal(
                onPressed: () {
                  vm.showEula().then((value) => vm.refresh());
                },
                child: const Text('show EULA'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: FutureBuilder<bool>(
                  future: vm.eulaAccepted(),
                  builder: (context, boolEulaAccepted) {
                    return Visibility(
                      visible: boolEulaAccepted.data ?? false,
                      child: FilledButton(
                        onPressed: () {
                          vm.goToChooseStorage().then((value) => vm.refresh());
                        },
                        child: const Text('create or select another file'),
                      ),
                    );
                  }),
            ),
            FutureBuilder<bool>(
                future: vm.eulaAccepted(),
                builder: (context, boolEulaAccepted) {
                  return Visibility(
                      visible: boolEulaAccepted.data ?? false,
                      child: FutureBuilder<List<BlastFile>>(
                          future: vm.recentFiles(),
                          builder: (context, listFiles) {
                            return Expanded(
                              child: Container(
                                child: _buildRecentFilesList(listFiles.data ?? [], vm),
                              ),
                            );
                          }));
                }),
            FutureBuilder<bool>(
                future: vm.eulaNotAccepted(),
                builder: (context, boolEulaNotAccepted) {
                  return Visibility(
                    visible: boolEulaNotAccepted.data ?? false,
                    child: Text("you must accept the EULA to use this app", style: _textTheme.labelMedium),
                  );
                }),
          ],
        )),
        floatingActionButton: FutureBuilder<ThemeMode>(
          future: vm.currentThemeMode,
          builder: (context, themeMode) {
            return IconButton(
              icon: Icon(
                themeMode.data == ThemeMode.light
                    ? Icons.light_mode
                    : (themeMode.data == ThemeMode.dark ? Icons.dark_mode : Icons.auto_awesome),
                color: _theme.colorScheme.tertiary,
              ),
              onPressed: () {
                vm.toggleLightDarkMode().then((value) {
                  BlastApp.of(context).changeTheme(value);
                  vm.refresh();
                });
              },
              tooltip: 'system/light/dark mode',
            );
          },
        ));
  }

  ListView _buildRecentFilesList(List<BlastFile> files, SplashViewModel vm) {
    if (vm.isLoading) {
      context.loaderOverlay.show();
    } else {
      context.loaderOverlay.hide();
    }

    var myList = ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, file) {
        return Padding(
            padding: const EdgeInsets.all(6),
            child: Material(
                borderRadius: BorderRadius.circular(6),
                elevation: 1,
                color: _theme.colorScheme.surface,
                shadowColor: _theme.colorScheme.onSurface,
                surfaceTintColor: _theme.colorScheme.onBackground,
                type: MaterialType.card,
                child: ListTile(
                  //leading: Image.asset("assets/general/app-icon.png"),
                  leading: Row(mainAxisSize: MainAxisSize.min, children: [
                    Image.asset("assets/storage/${files[file].cloudId}.png", width: 48, height: 48),
                    Text(" > ", style: _textTheme.headlineSmall),
                    Image.asset("assets/general/app-icon.png"),
                  ]),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Cloud>(
                        future: vm.getCloudStorageById(files[file].cloudId),
                        builder: (context, cloud) {
                          return Row(
                            children: [
                              Text(files[file].fileName, style: _textTheme.headlineSmall),
                              Text(
                                " - ",
                                style: _textTheme.labelLarge,
                              ),
                              Expanded(
                                  child: Text(cloud.data?.name ?? "",
                                      overflow: TextOverflow.ellipsis, maxLines: 1, style: _textTheme.labelSmall))
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        "URI: ",
                        style: _textTheme.labelSmall,
                      ),
                      Expanded(
                          child: Text(files[file].fileUrl,
                              style: _textTheme.labelSmall, overflow: TextOverflow.ellipsis, maxLines: 1)),
                    ],
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.cancel, color: _theme.colorScheme.error),
                      onPressed: () async {
                        await vm.removeFromRecent(files[file]).then((value) => vm.refresh());
                      }),
                  onTap: () async {
                    await vm.goToRecentFile(files[file]).then((value) => vm.refresh()).catchError((error) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Unable to open selected file, error: $error")));
                    });
                  },
                )));
      },
    );

    return myList;
  }
}
