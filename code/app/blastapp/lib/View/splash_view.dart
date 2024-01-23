import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/splash_view_model.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:flutter/material.dart';
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

  Widget _buildScaffold(BuildContext context, SplashViewModel vm) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const Text('Hello World!'),
          const Text('I am the splash screen!'),
          TextButton(
            onPressed: () {
              vm.showEula().then((value) => vm.refresh());
            },
            child: const Text('show EULA'),
          ),
          FutureBuilder<bool>(
              future: vm.eulaAccepted(),
              builder: (context, boolEulaAccepted) {
                return Visibility(
                  visible: boolEulaAccepted.data ?? false,
                  child: TextButton(
                    onPressed: () {
                      vm.goToChooseStorage().then((value) => vm.refresh());
                    },
                    child: const Text('create or select another file'),
                  ),
                );
              }),
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
                  child: const Text("you must accept the EULA to use this app",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                );
              }),
        ],
      )),
    );
  }

  ListView _buildRecentFilesList(List<BlastFile> files, SplashViewModel vm) {
    var myList = ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, file) {
        return ListTile(
          leading: const Icon(Icons.article),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Cloud>(
                future: vm.getCloudStorageById(files[file].cloudId),
                builder: (context, cloud) {
                  return Row(children: [
                    Text(cloud.data?.name ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text(" -"),
                    Text(files[file].fileName),
                  ]);
                },
              ),
              Row(
                children: [
                  const Text("URI: "),
                  Text(files[file].fileUrl, style: const TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            ],
          ),
          onTap: () async {
            vm.goToRecentFile(files[file]).then((value) => vm.refresh());
          },
        );
      },
    );

    return myList;
  }
}
