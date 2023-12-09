import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/choose_file_viewmodel.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ChooseFileView extends StatefulWidget {
  final Cloud cloud;

  const ChooseFileView({super.key, required this.cloud});

  @override
  State<StatefulWidget> createState() => _ChooseFileViewState();
}

class _ChooseFileViewState extends State<ChooseFileView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChooseFileViewModel(context),
      child: Consumer<ChooseFileViewModel>(
        builder: (context, viewmodel, child) =>
            _buildScaffold(context, viewmodel),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, ChooseFileViewModel vm) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          const Text('choose to create a file'),
          TextButton(
            onPressed: () {
              //Navigator.pop(context);
            },
            child: const Text('new file'),
          ),
          const Text('or to open an existing one'),
          Expanded(
            child: Container(
              child: _buildfileList(),
            ),
          ),
        ],
      ),
    ));
  }

  ListView _buildfileList() {
    var myList = ListView.builder(
      itemCount: 100,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.article),
          title: Text('fileItem$index.blast'),
          onTap: () {
            AlertDialog(
                title: Text("hello"),
                content: Text("World"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('close'),
                  ),
                ]);
          },
        );
      },
    );

    return myList;
  }
}

class ChooseFileViewOld extends StatelessWidget {
  final Cloud cloud;

  ChooseFileViewOld({super.key, required this.cloud}) {
    CurrentFileService().setCloud(cloud);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          const Text('choose to create a file'),
          TextButton(
            onPressed: () {
              //Navigator.pop(context);
            },
            child: const Text('new file'),
          ),
          const Text('or to open an existing one'),
          Expanded(
            child: Container(
              child: _buildfileList(),
            ),
          ),
        ],
      ),
    ));
  }

  ListView _buildfileList() {
    var myList = ListView.builder(
      itemCount: 100,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.article),
          title: Text('item$index.blast'),
          onTap: () {
            AlertDialog(
                title: Text("hello"),
                content: Text("world"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('close'),
                  ),
                ]);
          },
        );
      },
    );

    return myList;
  }
}
