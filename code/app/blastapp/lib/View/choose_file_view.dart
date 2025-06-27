import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/choose_file_viewmodel.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
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

  late BlastWidgetFactory _widgetFactory;

  Widget _buildScaffold(BuildContext context, ChooseFileViewModel vm) {
    _widgetFactory = BlastWidgetFactory(context);

    return Container(
        color: _widgetFactory.theme.colorScheme.surface,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: _widgetFactory.theme.colorScheme.surface,
                floatingActionButton: Tooltip(
                    message: 'create a new file',
                    textStyle: _widgetFactory.textTooltip.labelSmall,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Tooltip(
                              message: 'go up one directory',
                              textStyle: _widgetFactory.textTooltip.labelSmall,
                              child: IconButton(
                                  onPressed: () {
                                    vm.upDirectoryCommand();
                                  },
                                  icon: Icon(
                                    Icons.drive_folder_upload,
                                    color: _widgetFactory.theme.colorScheme.tertiary,
                                    size: 48,
                                  ))),
                          Text(
                            'current path: ',
                            style: _widgetFactory.textTheme.bodyLarge,
                          ),
                          FutureBuilder<String>(
                            future: vm.currentPath,
                            builder: (context, currentPath) => Flexible(
                                child: Text(
                              currentPath.data ?? "",
                              style: _widgetFactory.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            )),
                          ),
                          FutureBuilder<String>(
                              future: vm.currentPath,
                              builder: (context, currentPath) {
                                return Tooltip(
                                    message: 'copy current path to clipboard',
                                    textStyle: _widgetFactory.textTooltip.labelSmall,
                                    child: IconButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: currentPath.data ?? ""));
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text("current path copied to clipboard!",
                                                  style: _widgetFactory.textTooltip.labelSmall)));
                                        },
                                        icon: const Icon(Icons.copy)));
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
                ))));
  }

  Widget _buildfileList(List<CloudObject> listFiles, ChooseFileViewModel vm) {
    if (vm.isLoading) {
      context.loaderOverlay.show();
    } else {
      context.loaderOverlay.hide();
    }

    if (listFiles.isEmpty) {
      return Center(child: Text("No files found", style: _widgetFactory.textTheme.bodyLarge));
    }

    var myList = ListView.builder(
      itemCount: listFiles.length,
      itemBuilder: (context, index) {
        String name = listFiles[index].name;
        String path = listFiles[index].path;

        Widget leadingIcon;
        if (listFiles[index].isDirectory) {
          leadingIcon = Icon(Icons.folder, size: 48, color: _widgetFactory.theme.colorScheme.tertiary);
        } else {
          if (listFiles[index].name.endsWith(".blast")) {
            leadingIcon = Image.asset("assets/general/app-icon.png", width: 48, height: 48);
          } else {
            leadingIcon = Icon(Icons.article, size: 48, color: _widgetFactory.theme.colorScheme.primary);
          }
        }

        return Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Material(
                borderRadius: BorderRadius.circular(6),
                elevation: 1,
                color: _widgetFactory.theme.colorScheme.surface,
                shadowColor: _widgetFactory.theme.colorScheme.onSurface,
                surfaceTintColor: _widgetFactory.theme.colorScheme.surface,
                type: MaterialType.card,
                child: ListTile(
                  leading: leadingIcon, // Icon(listFiles[index].isDirectory ? Icons.folder : Icons.article),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(path),
                  onTap: () async {
                    await vm.selectItem(listFiles[index]).catchError((error) {
                      String errorMessage = "unable to open selected file, reason: ${error.toString()}";

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
                    });
                  },
                )));
      },
    );

    return myList;
  }
}
