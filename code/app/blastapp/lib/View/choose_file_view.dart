import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/choose_file_viewmodel.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:flutter/material.dart';
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
        body: Center(
      child: Column(
        children: [
          AppBar(
            title: const Text("Choose a file"),
          ),
          const Text('choose to create a file'),
          TextButton(
            onPressed: () {
              vm.newFileCommand();
            },
            child: const Text('new file'),
          ),
          const Text('or to open an existing one'),
          TextButton(
              child: const Text('back'),
              onPressed: () {
                vm.upDirectoryCommand();
              }),
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

  ListView _buildfileList(List<CloudObject> listFiles, ChooseFileViewModel vm) {
    var myList = ListView.builder(
      itemCount: listFiles.length,
      itemBuilder: (context, index) {
        String name = listFiles[index].name;
        String path = listFiles[index].path;

        return ListTile(
          leading: Icon(listFiles[index].isDirectory ? Icons.folder : Icons.article),
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
            await vm.selectItem(listFiles[index]).catchError((e) => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("unable to open selected file, Error: ${e.toString()}"))));
          },
        );
      },
    );

    return myList;
  }
}
