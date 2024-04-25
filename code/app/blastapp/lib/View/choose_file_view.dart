import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/choose_file_viewmodel.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ChooseFileView extends StatefulWidget {
  const ChooseFileView({super.key});

  @override
  State<StatefulWidget> createState() => _ChooseFileViewState();
}

class _ChooseFileViewState extends State<ChooseFileView> {
  _ChooseFileViewState();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChooseFileViewModel(context),
      child: Consumer<ChooseFileViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, ChooseFileViewModel vm) {
    return Scaffold(
        floatingActionButton: Tooltip(
            message: 'create a new file',
            child: FloatingActionButton(
              onPressed: () {
                vm.newFileCommand();
              },
              child: const Icon(Icons.note_add),
            )),
        body: Center(
          child: Column(
            children: [
              AppBar(
                title: const Text("Choose a file"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () {
                        vm.upDirectoryCommand();
                      },
                      icon: const Icon(Icons.drive_folder_upload)),
                  const Text('current path: '),
                  FutureBuilder<String>(
                    future: vm.currentPath,
                    builder: (context, currentPath) => Flexible(
                        child: Text(
                      currentPath.data ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    )),
                  ),
                  FutureBuilder<String>(
                      future: vm.currentPath,
                      builder: (context, currentPath) {
                        return IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: currentPath.data ?? ""));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text("current path copied to clipboard!")));
                            },
                            icon: const Icon(Icons.copy));
                      }),
                ],
              ),
              FutureBuilder<List<CloudObject>>(
                  future: vm.getFiles(),
                  builder: (context, listFiles) {
                    return Expanded(
                      child: Container(
                        child: _buildfileList(listFiles.data ?? [], vm),
                      ),
                    );
                  }),
            ],
          ),
        ));
  }

  Widget _buildfileList(List<CloudObject> listFiles, ChooseFileViewModel vm) {
    if (vm.isLoading) {
      context.loaderOverlay.show();
    } else {
      context.loaderOverlay.hide();
    }

    if (listFiles.isEmpty) {
      return const Center(child: Text("No files found"));
    }

    var myList = ListView.builder(
      itemCount: listFiles.length,
      itemBuilder: (context, index) {
        String name = listFiles[index].name;
        String path = listFiles[index].path;

        Widget leadingIcon;
        if (listFiles[index].isDirectory) {
          leadingIcon = const Icon(Icons.folder, size: 48);
        } else {
          if (listFiles[index].name.endsWith(".blast")) {
            leadingIcon = Image.asset("assets/general/app-icon.png", width: 48, height: 48);
          } else {
            leadingIcon = const Icon(Icons.article, size: 48);
          }
        }

        return ListTile(
          leading: leadingIcon, // Icon(listFiles[index].isDirectory ? Icons.folder : Icons.article),
          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(path),
                ],
              ),
            ],
          ),
          onTap: () async {
            await vm.selectItem(listFiles[index]).catchError((error) {
              String errorMessage = "unable to open selected file, reason: ${error.toString()}";

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
            });
          },
        );
      },
    );

    return myList;
  }
}
