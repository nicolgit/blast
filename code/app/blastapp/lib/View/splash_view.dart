import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/splash_viewmodel.dart';
import 'package:blastapp/main.dart';
import 'package:blastapp/blastwidget/animated_logo.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/secrets.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final viewModel = SplashViewModel();

  @override
  void initState() {
    super.initState();

    // open the most recent file on first load
    viewModel.context = context;
    viewModel.openMostRecentFile();

    viewModel.isInitializing = false;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: Consumer<SplashViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late ThemeData _theme;
  late TextTheme _textTheme;

  Widget _buildScaffold(BuildContext context, SplashViewModel vm) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);

    return Container(
        color: _theme.colorScheme.surface,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: _theme.colorScheme.surface,
                body: FutureBuilder(
                    future: vm.isInitializingAsync(),
                    builder: (context, isInitializing) {
                      if (isInitializing.data == true) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return _buildBody(context, vm);
                      }
                    }),
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
                          if (!context.mounted) return;
                          BlastApp.of(context).changeTheme(value);

                          vm.refresh();
                        });
                      },
                      tooltip: 'system/light/dark mode',
                    );
                  },
                ))));
  }

  Widget _buildBody(context, SplashViewModel vm) {
    return SingleChildScrollView(
        child: Center(
            child: Column(
      children: [
        const SizedBox(height: 24.0),
        const AnimatedLogo(
          width: 120,
          height: 120,
          assetPath: 'assets/general/app-icon.png',
          oscillation: true,
        ),
        const SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(children: [
            Text(
              "⭐️ BLAST ⭐️",
              style: _textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              "your passwords, safe and sound.",
              style: _textTheme.labelSmall,
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
            onPressed: () async {
              await vm.showEula();
              vm.refresh();
            },
            child: const Text('show License'),
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
                    child: const Text('create or select an existing file'),
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
                        final screenWidth = MediaQuery.of(context).size.width;
                        final maxWidth = screenWidth < 450 ? screenWidth - 32 : 450.0; // 16px padding on each side
                        return Container(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: _buildRecentFilesList(listFiles.data ?? [], vm),
                        );
                      }));
            }),
        FutureBuilder<bool>(
            future: vm.eulaNotAccepted(),
            builder: (context, boolEulaNotAccepted) {
              return Visibility(
                visible: boolEulaNotAccepted.data ?? false,
                child: Text("you must accept the End User Licence Agreement to use this app",
                    style: _textTheme.labelMedium),
              );
            }),
      ],
    )));
  }

  Widget _buildRecentFilesList(List<BlastFile> files, SplashViewModel vm) {
    if (vm.isLoading) {
      context.loaderOverlay.show();
    } else {
      context.loaderOverlay.hide();
    }

    // Check if files list is empty or null
    if (files.isEmpty) {
      return Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/general/empty-list.json',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 16),
            Text(
              'No recent files',
              style: _textTheme.titleMedium,
            ),
            Text(
              'Create or select an existing file to get started',
              style: _textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    var myList = ListView.builder(
      shrinkWrap: true,
      itemCount: files.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, file) => _buildRecentFileItem(context, files, file, vm),
    );

    return myList;
  }

  Widget _buildRecentFileItem(BuildContext context, List<BlastFile> files, int file, SplashViewModel vm) {
    return Padding(
        padding: const EdgeInsets.all(6),
        child: Dismissible(
            key: Key(files[file].fileUrl),
            onDismissed: (direction) async {
              if (direction == DismissDirection.endToStart) {
                await vm.removeFromRecent(files[file]).then((value) => vm.refresh());
              } else {
                await vm.goToRecentFile(files[file]);
              }
            },
            secondaryBackground: Container(
              color: _theme.colorScheme.error,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Icons.cancel, color: _theme.colorScheme.onError),
                  ),
                ],
              ),
            ),
            background: Container(
              color: _theme.colorScheme.inversePrimary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Icons.file_open, color: _theme.colorScheme.onPrimary),
                  ),
                ],
              ),
            ),
            child: Material(
                borderRadius: BorderRadius.circular(6),
                elevation: 1,
                color: _theme.colorScheme.surface,
                shadowColor: _theme.colorScheme.onSurface,
                surfaceTintColor: _theme.colorScheme.onSurface,
                type: MaterialType.card,
                child: FutureBuilder<Cloud>(
                    future: vm.getCloudStorageById(files[file].cloudId),
                    builder: (context, cloud) {
                      return ListTile(
                          onTap: () {
                            vm.goToRecentFile(files[file]);
                          },
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Image.asset("assets/storage/${files[file].cloudId}.png", width: 72, height: 72),
                                //Text(" > ", style: _textTheme.headlineSmall),
                                //Image.asset("assets/general/app-icon.png", width: 48, height: 48),
                              ]),
                              Text(files[file].fileName,
                                  style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              Text("${cloud.data?.name} ${files[file].fileUrl}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: _textTheme.labelSmall)
                            ],
                          ));
                    }))));
  }
}
