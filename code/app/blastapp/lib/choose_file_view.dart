import 'package:flutter/material.dart';

class ChooseFileView extends StatelessWidget {
  const ChooseFileView({super.key});

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
