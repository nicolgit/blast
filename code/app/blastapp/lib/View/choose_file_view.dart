import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';

class ChooseFileView extends StatelessWidget {
  final Cloud cloud;

  ChooseFileView({super.key, required this.cloud}) {
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
